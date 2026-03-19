import type { Metadata } from 'next';
import { notFound } from 'next/navigation';
import { supabase, type Post } from '@/lib/supabase';

export const revalidate = 3600;

interface PageProps {
  params: Promise<{ id: string }>;
}

async function getPost(id: string): Promise<Post | null> {
  const { data } = await supabase
    .from('posts')
    .select(
      '*, users!posts_user_id_fkey(username, full_name, avatar_url)'
    )
    .eq('id', id)
    .eq('is_deleted', false)
    .maybeSingle();

  return data as Post | null;
}

export async function generateStaticParams() {
  const { data } = await supabase
    .from('posts')
    .select('id')
    .eq('is_deleted', false)
    .order('created_at', { ascending: false })
    .limit(100);

  return (data ?? []).map((post) => ({ id: post.id }));
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { id } = await params;
  const post = await getPost(id);

  if (!post) {
    return { title: 'Post Not Found' };
  }

  const title = post.content
    ? post.content.substring(0, 60) + (post.content.length > 60 ? '...' : '')
    : `Post by ${post.users?.full_name}`;

  const description = post.content
    ? post.content.substring(0, 160)
    : `A post by ${post.users?.full_name} on Nûbar`;

  const images = post.thumbnail_url
    ? [post.thumbnail_url]
    : post.media_urls?.length
      ? [post.media_urls[0]]
      : [];

  return {
    title,
    description,
    openGraph: {
      title,
      description,
      type: 'article',
      images,
      authors: [post.users?.full_name ?? 'Nûbar User'],
      publishedTime: post.created_at,
      locale: post.language === 'ckb' || post.language === 'ar' ? 'ar' : 'ku_TR',
    },
    twitter: {
      card: images.length > 0 ? 'summary_large_image' : 'summary',
      title,
      description,
      images,
    },
  };
}

export default async function PostPage({ params }: PageProps) {
  const { id } = await params;
  const post = await getPost(id);

  if (!post) {
    notFound();
  }

  return (
    <main style={{ maxWidth: '700px', margin: '0 auto', padding: '24px' }}>
      <a href="/" style={{ color: '#2D6A4F', textDecoration: 'none', marginBottom: '24px', display: 'block' }}>
        ← Nûbar
      </a>

      <article
        style={{
          backgroundColor: '#fff',
          borderRadius: '12px',
          padding: '24px',
          boxShadow: '0 1px 3px rgba(0,0,0,0.08)',
        }}
      >
        <header style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
          {post.users?.avatar_url && (
            <img
              src={post.users.avatar_url}
              alt={post.users.full_name}
              width={48}
              height={48}
              style={{ borderRadius: '50%' }}
            />
          )}
          <div>
            <a
              href={`/user/${post.users?.username}`}
              style={{ fontWeight: 'bold', color: '#1a1a1a', textDecoration: 'none' }}
            >
              {post.users?.full_name}
            </a>
            <div style={{ color: '#888', fontSize: '0.875rem' }}>
              @{post.users?.username} ·{' '}
              {new Date(post.created_at).toLocaleDateString('ku', {
                year: 'numeric',
                month: 'long',
                day: 'numeric',
              })}
            </div>
          </div>
        </header>

        {post.content && (
          <p style={{ fontSize: '1.125rem', lineHeight: 1.7, margin: '0 0 16px' }}>
            {post.content}
          </p>
        )}

        {post.media_urls && post.media_urls.length > 0 && (
          <div style={{ display: 'grid', gap: '8px', marginBottom: '16px' }}>
            {post.media_urls.map((url, i) => (
              <img
                key={i}
                src={url}
                alt={`Media ${i + 1}`}
                style={{ width: '100%', borderRadius: '8px' }}
              />
            ))}
          </div>
        )}

        <footer style={{ display: 'flex', gap: '24px', color: '#888', borderTop: '1px solid #eee', paddingTop: '12px' }}>
          <span>❤ {post.like_count} Hez kirin</span>
          <span>💬 {post.comment_count} Şîrove</span>
          <span>🔄 {post.repost_count} Parve kirin</span>
        </footer>
      </article>

      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify({
            '@context': 'https://schema.org',
            '@type': 'SocialMediaPosting',
            headline: post.content?.substring(0, 110) ?? 'Nûbar Post',
            author: {
              '@type': 'Person',
              name: post.users?.full_name,
              url: `https://nubar.app/user/${post.users?.username}`,
            },
            datePublished: post.created_at,
            interactionStatistic: [
              {
                '@type': 'InteractionCounter',
                interactionType: 'https://schema.org/LikeAction',
                userInteractionCount: post.like_count,
              },
              {
                '@type': 'InteractionCounter',
                interactionType: 'https://schema.org/CommentAction',
                userInteractionCount: post.comment_count,
              },
            ],
            inLanguage: post.language,
          }),
        }}
      />
    </main>
  );
}
