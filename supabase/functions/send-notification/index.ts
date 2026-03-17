import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { userId, type, actorId, postId, commentId } = await req.json()

    // Insert notification into database
    const { error: dbError } = await supabaseAdmin
      .from('notifications')
      .insert({
        user_id: userId,
        type: type,
        actor_id: actorId,
        post_id: postId || null,
        comment_id: commentId || null,
      })

    if (dbError) throw dbError

    // Send push notification via FCM
    const fcmKey = Deno.env.get('FCM_SERVER_KEY')
    if (fcmKey) {
      // Get user's FCM token (would be stored in users table or separate tokens table)
      const { data: userData } = await supabaseAdmin
        .from('users')
        .select('id')
        .eq('id', userId)
        .single()

      if (userData) {
        // FCM push notification would be sent here
        // This is a placeholder for the actual FCM implementation
      }
    }

    return new Response(JSON.stringify({ success: true }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
