-- Content publish integrity rules for studio and create flows.

ALTER TABLE posts
ADD CONSTRAINT posts_media_required_for_media_types CHECK (
  CASE
    WHEN type IN ('image', 'video', 'pdf', 'voice')
      THEN media_urls IS NOT NULL AND array_length(media_urls, 1) >= 1
    ELSE TRUE
  END
);

ALTER TABLE posts
ADD CONSTRAINT posts_quiz_metadata_shape CHECK (
  CASE
    WHEN type = 'quiz'
      THEN metadata ? 'quiz_question'
        AND metadata ? 'quiz_options'
        AND metadata ? 'quiz_correct_index'
    ELSE TRUE
  END
);

ALTER TABLE posts
ADD CONSTRAINT posts_thread_metadata_shape CHECK (
  CASE
    WHEN type = 'thread'
      THEN metadata ? 'thread_parts'
    ELSE TRUE
  END
);

ALTER TABLE posts
ADD CONSTRAINT posts_article_metadata_shape CHECK (
  CASE
    WHEN type = 'article'
      THEN metadata ? 'article_title'
    ELSE TRUE
  END
);

CREATE INDEX IF NOT EXISTS idx_posts_type_created_at
ON posts (type, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_posts_metadata_gin
ON posts USING gin (metadata);
