-- ============================================
-- Nûbar Database Schema
-- Initial migration
-- ============================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ============================================
-- Enums
-- ============================================
CREATE TYPE post_type AS ENUM ('text', 'image', 'video', 'pdf', 'mixed');
CREATE TYPE notification_type AS ENUM ('like', 'comment', 'follow', 'repost', 'mention', 'message');
CREATE TYPE community_role AS ENUM ('admin', 'moderator', 'member');
CREATE TYPE report_status AS ENUM ('pending', 'reviewed', 'resolved');
CREATE TYPE app_language AS ENUM ('ku', 'ckb', 'tr', 'ar', 'en');
CREATE TYPE app_theme AS ENUM ('nubar', 'dark', 'light', 'earth', 'ocean', 'amoled');

-- ============================================
-- Tables
-- ============================================

-- USERS
CREATE TABLE users (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  auth_id         UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  username        TEXT UNIQUE NOT NULL,
  full_name       TEXT NOT NULL,
  avatar_url      TEXT,
  bio             TEXT,
  website         TEXT,
  location        TEXT,
  verified        BOOLEAN DEFAULT FALSE,
  follower_count  INTEGER DEFAULT 0,
  following_count INTEGER DEFAULT 0,
  post_count      INTEGER DEFAULT 0,
  preferred_lang  app_language DEFAULT 'ku',
  preferred_theme app_theme DEFAULT 'nubar',
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- COMMUNITIES
CREATE TABLE communities (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name          TEXT NOT NULL,
  slug          TEXT UNIQUE NOT NULL,
  description   TEXT,
  avatar_url    TEXT,
  banner_url    TEXT,
  is_private    BOOLEAN DEFAULT FALSE,
  member_count  INTEGER DEFAULT 0,
  post_count    INTEGER DEFAULT 0,
  created_by    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- POSTS
CREATE TABLE posts (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content          TEXT,
  type             post_type NOT NULL DEFAULT 'text',
  media_urls       TEXT[],
  thumbnail_url    TEXT,
  community_id     UUID REFERENCES communities(id) ON DELETE SET NULL,
  original_post_id UUID REFERENCES posts(id) ON DELETE SET NULL,
  is_repost        BOOLEAN DEFAULT FALSE,
  view_count       INTEGER DEFAULT 0,
  like_count       INTEGER DEFAULT 0,
  comment_count    INTEGER DEFAULT 0,
  repost_count     INTEGER DEFAULT 0,
  bookmark_count   INTEGER DEFAULT 0,
  language         app_language DEFAULT 'ku',
  is_deleted       BOOLEAN DEFAULT FALSE,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

-- COMMENTS
CREATE TABLE comments (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id     UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  parent_id   UUID REFERENCES comments(id) ON DELETE CASCADE,
  content     TEXT NOT NULL,
  like_count  INTEGER DEFAULT 0,
  is_deleted  BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- LIKES
CREATE TABLE likes (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id    UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, post_id)
);

-- COMMENT LIKES
CREATE TABLE comment_likes (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  comment_id UUID NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, comment_id)
);

-- REPOSTS
CREATE TABLE reposts (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id    UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, post_id)
);

-- BOOKMARKS
CREATE TABLE bookmarks (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id    UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, post_id)
);

-- FOLLOWS
CREATE TABLE follows (
  follower_id  UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (follower_id, following_id)
);

-- COMMUNITY MEMBERS
CREATE TABLE community_members (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  user_id      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role         community_role DEFAULT 'member',
  joined_at    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(community_id, user_id)
);

-- NOTIFICATIONS
CREATE TABLE notifications (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type       notification_type NOT NULL,
  actor_id   UUID REFERENCES users(id) ON DELETE CASCADE,
  post_id    UUID REFERENCES posts(id) ON DELETE CASCADE,
  comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
  is_read    BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- MESSAGES
CREATE TABLE messages (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content     TEXT,
  media_url   TEXT,
  is_read     BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- POLLS
CREATE TABLE polls (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id    UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  question   TEXT NOT NULL,
  options    JSONB NOT NULL,
  ends_at    TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- POLL VOTES
CREATE TABLE poll_votes (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  poll_id    UUID NOT NULL REFERENCES polls(id) ON DELETE CASCADE,
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  option_key TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(poll_id, user_id)
);

-- REPORTS
CREATE TABLE reports (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reporter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id     UUID REFERENCES posts(id) ON DELETE CASCADE,
  comment_id  UUID REFERENCES comments(id) ON DELETE CASCADE,
  reason      TEXT NOT NULL,
  status      report_status DEFAULT 'pending',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- HASHTAGS
CREATE TABLE hashtags (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name       TEXT UNIQUE NOT NULL,
  post_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- POST HASHTAGS
CREATE TABLE post_hashtags (
  post_id    UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  hashtag_id UUID NOT NULL REFERENCES hashtags(id) ON DELETE CASCADE,
  PRIMARY KEY (post_id, hashtag_id)
);

-- ============================================
-- Indexes
-- ============================================
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_community_id ON posts(community_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id, is_read);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_receiver ON messages(receiver_id);
CREATE INDEX idx_posts_search ON posts USING gin(to_tsvector('simple', content));
CREATE INDEX idx_users_username ON users USING gin(username gin_trgm_ops);
CREATE INDEX idx_hashtags_name ON hashtags USING gin(name gin_trgm_ops);
CREATE INDEX idx_community_slug ON communities(slug);

-- ============================================
-- Row Level Security
-- ============================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE comment_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE reposts ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE communities ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE polls ENABLE ROW LEVEL SECURITY;
ALTER TABLE poll_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE hashtags ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_hashtags ENABLE ROW LEVEL SECURITY;

-- USERS policies
CREATE POLICY "Users are viewable by everyone" ON users FOR SELECT USING (TRUE);
CREATE POLICY "Users can insert own profile" ON users FOR INSERT WITH CHECK (auth.uid() = auth_id);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = auth_id);

-- POSTS policies
CREATE POLICY "Public posts are viewable by everyone" ON posts FOR SELECT USING (is_deleted = FALSE);
CREATE POLICY "Users can create posts" ON posts FOR INSERT WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Users can update own posts" ON posts FOR UPDATE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Users can delete own posts" ON posts FOR DELETE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- COMMENTS policies
CREATE POLICY "Comments are viewable by everyone" ON comments FOR SELECT USING (is_deleted = FALSE);
CREATE POLICY "Users can create comments" ON comments FOR INSERT WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Users can update own comments" ON comments FOR UPDATE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Users can delete own comments" ON comments FOR DELETE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- LIKES policies
CREATE POLICY "Likes are viewable by everyone" ON likes FOR SELECT USING (TRUE);
CREATE POLICY "Users can like" ON likes FOR INSERT WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Users can unlike" ON likes FOR DELETE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- COMMENT LIKES policies
CREATE POLICY "Comment likes are viewable by everyone" ON comment_likes FOR SELECT USING (TRUE);
CREATE POLICY "Users can like comments" ON comment_likes FOR INSERT WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Users can unlike comments" ON comment_likes FOR DELETE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- REPOSTS policies
CREATE POLICY "Reposts are viewable by everyone" ON reposts FOR SELECT USING (TRUE);
CREATE POLICY "Users can repost" ON reposts FOR INSERT WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Users can undo repost" ON reposts FOR DELETE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- BOOKMARKS policies
CREATE POLICY "Users see own bookmarks" ON bookmarks FOR SELECT USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Users can bookmark" ON bookmarks FOR INSERT WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Users can remove bookmark" ON bookmarks FOR DELETE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- FOLLOWS policies
CREATE POLICY "Follows are viewable by everyone" ON follows FOR SELECT USING (TRUE);
CREATE POLICY "Users can follow" ON follows FOR INSERT WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = follower_id));
CREATE POLICY "Users can unfollow" ON follows FOR DELETE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = follower_id));

-- COMMUNITIES policies
CREATE POLICY "Public communities are viewable" ON communities FOR SELECT USING (TRUE);
CREATE POLICY "Users can create communities" ON communities FOR INSERT WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = created_by));
CREATE POLICY "Community creators can update" ON communities FOR UPDATE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = created_by));

-- COMMUNITY MEMBERS policies
CREATE POLICY "Community members are viewable" ON community_members FOR SELECT USING (TRUE);
CREATE POLICY "Users can join communities" ON community_members FOR INSERT WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Users can leave communities" ON community_members FOR DELETE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- NOTIFICATIONS policies
CREATE POLICY "Users see own notifications" ON notifications FOR SELECT USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "System can create notifications" ON notifications FOR INSERT WITH CHECK (TRUE);
CREATE POLICY "Users can update own notifications" ON notifications FOR UPDATE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- MESSAGES policies
CREATE POLICY "Users see own messages" ON messages FOR SELECT USING (
  auth.uid() = (SELECT auth_id FROM users WHERE id = sender_id) OR
  auth.uid() = (SELECT auth_id FROM users WHERE id = receiver_id)
);
CREATE POLICY "Users can send messages" ON messages FOR INSERT WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = sender_id));
CREATE POLICY "Users can update own messages" ON messages FOR UPDATE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = sender_id) OR auth.uid() = (SELECT auth_id FROM users WHERE id = receiver_id));

-- POLLS policies
CREATE POLICY "Polls are viewable by everyone" ON polls FOR SELECT USING (TRUE);
CREATE POLICY "Post owners can create polls" ON polls FOR INSERT WITH CHECK (TRUE);

-- POLL VOTES policies
CREATE POLICY "Poll votes are viewable by everyone" ON poll_votes FOR SELECT USING (TRUE);
CREATE POLICY "Users can vote" ON poll_votes FOR INSERT WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- REPORTS policies
CREATE POLICY "Users can create reports" ON reports FOR INSERT WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = reporter_id));

-- HASHTAGS policies
CREATE POLICY "Hashtags are viewable by everyone" ON hashtags FOR SELECT USING (TRUE);
CREATE POLICY "Hashtags can be created" ON hashtags FOR INSERT WITH CHECK (TRUE);

-- POST HASHTAGS policies
CREATE POLICY "Post hashtags are viewable by everyone" ON post_hashtags FOR SELECT USING (TRUE);
CREATE POLICY "Post hashtags can be created" ON post_hashtags FOR INSERT WITH CHECK (TRUE);

-- ============================================
-- Triggers for counter updates
-- ============================================

-- Like count on posts
CREATE OR REPLACE FUNCTION update_post_like_count() RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE posts SET like_count = like_count + 1 WHERE id = NEW.post_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE posts SET like_count = like_count - 1 WHERE id = OLD.post_id;
    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_like_change
  AFTER INSERT OR DELETE ON likes
  FOR EACH ROW EXECUTE FUNCTION update_post_like_count();

-- Comment count on posts
CREATE OR REPLACE FUNCTION update_post_comment_count() RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE posts SET comment_count = comment_count + 1 WHERE id = NEW.post_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE posts SET comment_count = comment_count - 1 WHERE id = OLD.post_id;
    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_comment_change
  AFTER INSERT OR DELETE ON comments
  FOR EACH ROW EXECUTE FUNCTION update_post_comment_count();

-- Repost count on posts
CREATE OR REPLACE FUNCTION update_post_repost_count() RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE posts SET repost_count = repost_count + 1 WHERE id = NEW.post_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE posts SET repost_count = repost_count - 1 WHERE id = OLD.post_id;
    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_repost_change
  AFTER INSERT OR DELETE ON reposts
  FOR EACH ROW EXECUTE FUNCTION update_post_repost_count();

-- Bookmark count on posts
CREATE OR REPLACE FUNCTION update_post_bookmark_count() RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE posts SET bookmark_count = bookmark_count + 1 WHERE id = NEW.post_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE posts SET bookmark_count = bookmark_count - 1 WHERE id = OLD.post_id;
    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_bookmark_change
  AFTER INSERT OR DELETE ON bookmarks
  FOR EACH ROW EXECUTE FUNCTION update_post_bookmark_count();

-- Follower/following counts
CREATE OR REPLACE FUNCTION update_follow_counts() RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE users SET following_count = following_count + 1 WHERE id = NEW.follower_id;
    UPDATE users SET follower_count = follower_count + 1 WHERE id = NEW.following_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE users SET following_count = following_count - 1 WHERE id = OLD.follower_id;
    UPDATE users SET follower_count = follower_count - 1 WHERE id = OLD.following_id;
    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_follow_change
  AFTER INSERT OR DELETE ON follows
  FOR EACH ROW EXECUTE FUNCTION update_follow_counts();

-- Post count on users
CREATE OR REPLACE FUNCTION update_user_post_count() RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE users SET post_count = post_count + 1 WHERE id = NEW.user_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE users SET post_count = post_count - 1 WHERE id = OLD.user_id;
    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_post_change
  AFTER INSERT OR DELETE ON posts
  FOR EACH ROW EXECUTE FUNCTION update_user_post_count();

-- Community member count
CREATE OR REPLACE FUNCTION update_community_member_count() RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE communities SET member_count = member_count + 1 WHERE id = NEW.community_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE communities SET member_count = member_count - 1 WHERE id = OLD.community_id;
    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_community_member_change
  AFTER INSERT OR DELETE ON community_members
  FOR EACH ROW EXECUTE FUNCTION update_community_member_count();

-- Comment like count
CREATE OR REPLACE FUNCTION update_comment_like_count() RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE comments SET like_count = like_count + 1 WHERE id = NEW.comment_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE comments SET like_count = like_count - 1 WHERE id = OLD.comment_id;
    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_comment_like_change
  AFTER INSERT OR DELETE ON comment_likes
  FOR EACH ROW EXECUTE FUNCTION update_comment_like_count();

-- ============================================
-- Realtime
-- ============================================
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
