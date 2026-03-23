-- Add Twitter-style post reply relation support.
ALTER TABLE posts
ADD COLUMN IF NOT EXISTS reply_to_post_id UUID REFERENCES posts(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_posts_reply_to_post_id
ON posts(reply_to_post_id);

CREATE INDEX IF NOT EXISTS idx_posts_user_created_at
ON posts(user_id, created_at DESC);
