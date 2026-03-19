-- Phase 4: User Blocking, Badges/Levels, Realtime support
-- Migration: 002_phase4_schema.sql

-- ============================================================
-- USER BLOCKS
-- ============================================================
CREATE TABLE user_blocks (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  blocker_id  UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  blocked_id  UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(blocker_id, blocked_id),
  CHECK (blocker_id != blocked_id)
);

CREATE INDEX idx_user_blocks_blocker ON user_blocks(blocker_id);
CREATE INDEX idx_user_blocks_blocked ON user_blocks(blocked_id);

ALTER TABLE user_blocks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own blocks"
  ON user_blocks FOR SELECT
  USING (auth.uid() = (SELECT auth_id FROM users WHERE id = blocker_id));

CREATE POLICY "Users can block others"
  ON user_blocks FOR INSERT
  WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = blocker_id));

CREATE POLICY "Users can unblock others"
  ON user_blocks FOR DELETE
  USING (auth.uid() = (SELECT auth_id FROM users WHERE id = blocker_id));

-- ============================================================
-- BADGES
-- ============================================================
CREATE TYPE badge_criteria AS ENUM (
  'post_count',
  'follower_count',
  'following_count',
  'comment_count',
  'like_received',
  'community_created',
  'first_post',
  'first_comment',
  'verified'
);

CREATE TABLE badges (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name            TEXT NOT NULL,
  description     TEXT,
  icon            TEXT NOT NULL,       -- Material icon name
  criteria_type   badge_criteria NOT NULL,
  criteria_value  INTEGER DEFAULT 1,   -- threshold value
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE user_badges (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  badge_id   UUID NOT NULL REFERENCES badges(id) ON DELETE CASCADE,
  earned_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, badge_id)
);

CREATE INDEX idx_user_badges_user ON user_badges(user_id);

ALTER TABLE badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Badges are viewable by everyone"
  ON badges FOR SELECT USING (TRUE);

CREATE POLICY "User badges are viewable by everyone"
  ON user_badges FOR SELECT USING (TRUE);

-- Only system/triggers can insert badges
CREATE POLICY "System can insert user badges"
  ON user_badges FOR INSERT
  WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- ============================================================
-- SEED DEFAULT BADGES
-- ============================================================
INSERT INTO badges (name, description, icon, criteria_type, criteria_value) VALUES
  ('Nûbar', 'First post on the platform', 'emoji_events', 'first_post', 1),
  ('Dengbêj', '10 posts published', 'music_note', 'post_count', 10),
  ('Çîrokbêj', '50 posts published', 'auto_stories', 'post_count', 50),
  ('Nivîskar', '100 posts published', 'edit_note', 'post_count', 100),
  ('Nasdar', '10 followers', 'people', 'follower_count', 10),
  ('Populer', '50 followers', 'trending_up', 'follower_count', 50),
  ('Stêrk', '100 followers', 'star', 'follower_count', 100),
  ('Rexnegir', 'First comment', 'chat', 'first_comment', 1),
  ('Civatger', 'Created a community', 'groups', 'community_created', 1),
  ('Pejirandî', 'Verified account', 'verified', 'verified', 1);

-- ============================================================
-- USER LEVEL FUNCTION
-- ============================================================
CREATE OR REPLACE FUNCTION get_user_level(p_post_count INTEGER, p_follower_count INTEGER)
RETURNS INTEGER AS $$
BEGIN
  IF p_post_count >= 100 AND p_follower_count >= 100 THEN
    RETURN 5;
  ELSIF p_post_count >= 50 AND p_follower_count >= 50 THEN
    RETURN 4;
  ELSIF p_post_count >= 25 AND p_follower_count >= 25 THEN
    RETURN 3;
  ELSIF p_post_count >= 10 AND p_follower_count >= 10 THEN
    RETURN 2;
  ELSE
    RETURN 1;
  END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================
-- ENABLE REALTIME for messages & notifications (if not already)
-- ============================================================
DO $$
BEGIN
  -- These might already be in the publication from migration 001
  -- Using IF NOT EXISTS pattern
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'messages'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE messages;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'notifications'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
  END IF;
END $$;
