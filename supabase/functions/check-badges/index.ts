// check-badges Edge Function
// Checks and awards badges to a user based on their activity stats.
// Called after significant actions (post, comment, follow, community creation).

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Verify JWT
    const authHeader = req.headers.get("Authorization")!;
    const {
      data: { user },
    } = await supabase.auth.getUser(
      authHeader.replace("Bearer ", "")
    );

    if (!user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Get user profile
    const { data: profile } = await supabase
      .from("users")
      .select("id, post_count, follower_count, following_count")
      .eq("auth_id", user.id)
      .single();

    if (!profile) {
      return new Response(JSON.stringify({ error: "Profile not found" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const userId = profile.id;

    // Get all available badges
    const { data: allBadges } = await supabase
      .from("badges")
      .select("*");

    // Get already earned badges
    const { data: earnedBadges } = await supabase
      .from("user_badges")
      .select("badge_id")
      .eq("user_id", userId);

    const earnedIds = new Set(
      (earnedBadges || []).map((b: { badge_id: string }) => b.badge_id)
    );

    // Get comment count
    const { count: commentCount } = await supabase
      .from("comments")
      .select("*", { count: "exact", head: true })
      .eq("user_id", userId);

    // Get created communities count
    const { count: communitiesCreated } = await supabase
      .from("communities")
      .select("*", { count: "exact", head: true })
      .eq("created_by", userId);

    // Check each badge
    const newBadges: string[] = [];

    for (const badge of allBadges || []) {
      if (earnedIds.has(badge.id)) continue;

      let earned = false;

      switch (badge.criteria_type) {
        case "first_post":
          earned = profile.post_count >= badge.criteria_value;
          break;
        case "post_count":
          earned = profile.post_count >= badge.criteria_value;
          break;
        case "follower_count":
          earned = profile.follower_count >= badge.criteria_value;
          break;
        case "following_count":
          earned = profile.following_count >= badge.criteria_value;
          break;
        case "comment_count":
          earned = (commentCount || 0) >= badge.criteria_value;
          break;
        case "first_comment":
          earned = (commentCount || 0) >= badge.criteria_value;
          break;
        case "community_created":
          earned = (communitiesCreated || 0) >= badge.criteria_value;
          break;
        case "verified":
          // Verified is manually assigned, skip auto-check
          break;
      }

      if (earned) {
        // Award badge
        await supabase.from("user_badges").insert({
          user_id: userId,
          badge_id: badge.id,
        });

        // Create notification
        await supabase.from("notifications").insert({
          user_id: userId,
          type: "badge",
          actor_id: userId,
        });

        newBadges.push(badge.name);
      }
    }

    return new Response(
      JSON.stringify({
        checked: (allBadges || []).length,
        newBadges,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
