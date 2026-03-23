-- ============================================
-- Nûbar Database Schema - Phase 6.5
-- Advanced Content Studio
-- ============================================

-- Add new content types to post_type enum
ALTER TYPE post_type ADD VALUE IF NOT EXISTS 'article';
ALTER TYPE post_type ADD VALUE IF NOT EXISTS 'quiz';
ALTER TYPE post_type ADD VALUE IF NOT EXISTS 'thread';
ALTER TYPE post_type ADD VALUE IF NOT EXISTS 'voice';

-- Add metadata column to posts for flexible storage
ALTER TABLE posts
ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;
