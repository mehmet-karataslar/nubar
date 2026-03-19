import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.SUPABASE_URL!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;

export const supabase = createClient(supabaseUrl, supabaseServiceKey);

export interface Post {
  id: string;
  user_id: string;
  content: string | null;
  type: string;
  media_urls: string[] | null;
  thumbnail_url: string | null;
  community_id: string | null;
  like_count: number;
  comment_count: number;
  repost_count: number;
  language: string;
  created_at: string;
  users: {
    username: string;
    full_name: string;
    avatar_url: string | null;
  };
}

export interface Community {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  avatar_url: string | null;
  banner_url: string | null;
  member_count: number;
  post_count: number;
  created_at: string;
}

export interface UserProfile {
  id: string;
  username: string;
  full_name: string;
  avatar_url: string | null;
  bio: string | null;
  website: string | null;
  location: string | null;
  verified: boolean;
  follower_count: number;
  following_count: number;
  post_count: number;
  created_at: string;
}
