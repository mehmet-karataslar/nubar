-- Harden content-related insert policies.

DROP POLICY IF EXISTS "Post owners can create polls" ON polls;
CREATE POLICY "Post owners can create polls"
ON polls
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM posts
    JOIN users ON users.id = posts.user_id
    WHERE posts.id = polls.post_id
      AND users.auth_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Post hashtags can be created" ON post_hashtags;
CREATE POLICY "Post hashtags can be created"
ON post_hashtags
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM posts
    JOIN users ON users.id = posts.user_id
    WHERE posts.id = post_hashtags.post_id
      AND users.auth_id = auth.uid()
  )
);
