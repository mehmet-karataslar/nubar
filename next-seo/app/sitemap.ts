import type { MetadataRoute } from 'next';
import { supabase } from '@/lib/supabase';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const baseUrl = 'https://nubar.app';

  // Fetch recent posts
  const { data: posts } = await supabase
    .from('posts')
    .select('id, created_at')
    .eq('is_deleted', false)
    .order('created_at', { ascending: false })
    .limit(500);

  // Fetch communities
  const { data: communities } = await supabase
    .from('communities')
    .select('slug, created_at')
    .limit(200);

  // Fetch users
  const { data: users } = await supabase
    .from('users')
    .select('username, created_at')
    .limit(500);

  const postUrls: MetadataRoute.Sitemap = (posts ?? []).map((post) => ({
    url: `${baseUrl}/post/${post.id}`,
    lastModified: new Date(post.created_at),
    changeFrequency: 'weekly' as const,
    priority: 0.7,
  }));

  const communityUrls: MetadataRoute.Sitemap = (communities ?? []).map((c) => ({
    url: `${baseUrl}/community/${c.slug}`,
    lastModified: new Date(c.created_at),
    changeFrequency: 'daily' as const,
    priority: 0.8,
  }));

  const userUrls: MetadataRoute.Sitemap = (users ?? []).map((u) => ({
    url: `${baseUrl}/user/${u.username}`,
    lastModified: new Date(u.created_at),
    changeFrequency: 'weekly' as const,
    priority: 0.6,
  }));

  return [
    {
      url: baseUrl,
      lastModified: new Date(),
      changeFrequency: 'daily',
      priority: 1,
    },
    ...communityUrls,
    ...postUrls,
    ...userUrls,
  ];
}
