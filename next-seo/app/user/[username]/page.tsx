import type { Metadata } from 'next';
import { notFound } from 'next/navigation';
import { supabase, type UserProfile, type Post } from '@/lib/supabase';

export const revalidate = 3600;

interface PageProps {
  params: Promise<{ username: string }>;
}

async function getUser(username: string): Promise<UserProfile | null> {
  const { data } = await supabase
    .from('users')
    .select('*')
    .eq('username', username)
    .maybeSingle();

  return data as UserProfile | null;
}

async function getUserPosts(userId: string): Promise<Post[]> {
  const { data } = await supabase
    .from('posts')
    .select('*, users!posts_user_id_fkey(username, full_name, avatar_url)')
    .eq('user_id', userId)
    .eq('is_deleted', false)
    .order('created_at', { ascending: false })
    .limit(20);

  return (data ?? []) as Post[];
}

export async function generateStaticParams() {
  const { data } = await supabase
    .from('users')
    .select('username')
    .limit(200);

  return (data ?? []).map((u) => ({ username: u.username }));
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { username } = await params;
  const user = await getUser(username);

  if (!user) {
    return { title: 'User Not Found' };
  }

  const title = `${user.full_name} (@${user.username})`;
  const description =
    user.bio ?? `${user.full_name} — ${user.follower_count} followers on Nûbar`;

  return {
    title,
    description,
    openGraph: {
      title: `${title} | Nûbar`,
      description,
      type: 'profile',
      images: user.avatar_url ? [user.avatar_url] : [],
    },
    twitter: {
      card: 'summary',
      title,
      description,
      images: user.avatar_url ? [user.avatar_url] : [],
    },
  };
}

export default async function UserProfilePage({ params }: PageProps) {
  const { username } = await params;
  const user = await getUser(username);

  if (!user) {
    notFound();
  }

  const posts = await getUserPosts(user.id);

  return (
    <main style={{ maxWidth: '700px', margin: '0 auto', padding: '24px' }}>
      <a href="/" style={{ color: '#2D6A4F', textDecoration: 'none', marginBottom: '24px', display: 'block' }}>
        ← Nûbar
      </a>

      <header
        style={{
          backgroundColor: '#fff',
          borderRadius: '12px',
          padding: '24px',
          marginBottom: '24px',
          boxShadow: '0 1px 3px rgba(0,0,0,0.08)',
          textAlign: 'center',
        }}
      >
        {user.avatar_url && (
          <img
            src={user.avatar_url}
            alt={user.full_name}
            width={100}
            height={100}
            style={{ borderRadius: '50%', marginBottom: '12px' }}
          />
        )}
        <h1 style={{ fontSize: '1.75rem', margin: '0 0 4px' }}>
          {user.full_name}
          {user.verified && (
            <span style={{ color: '#2D6A4F', marginLeft: '8px', fontSize: '1rem' }}>✓</span>
          )}
        </h1>
        <p style={{ color: '#888', margin: '0 0 12px' }}>@{user.username}</p>

        {user.bio && (
          <p style={{ maxWidth: '500px', margin: '0 auto 16px', lineHeight: 1.6 }}>
            {user.bio}
          </p>
        )}

        <div style={{ display: 'flex', justifyContent: 'center', gap: '24px', color: '#888' }}>
          <span><strong>{user.post_count}</strong> şandin</span>
          <span><strong>{user.follower_count}</strong> şopîner</span>
          <span><strong>{user.following_count}</strong> dişopîne</span>
        </div>

        {(user.location || user.website) && (
          <div style={{ marginTop: '12px', color: '#888', fontSize: '0.875rem' }}>
            {user.location && <span>📍 {user.location}</span>}
            {user.location && user.website && <span> · </span>}
            {user.website && <span>🔗 {user.website}</span>}
          </div>
        )}
      </header>

      <section>
        <h2 style={{ fontSize: '1.25rem', color: '#2D6A4F', marginBottom: '12px' }}>
          Şandin
        </h2>

        {posts.length === 0 ? (
          <p style={{ color: '#888', textAlign: 'center' }}>Hîn şandin tune ne</p>
        ) : (
          posts.map((post) => (
            <article
              key={post.id}
              style={{
                backgroundColor: '#fff',
                borderRadius: '12px',
                padding: '16px',
                marginBottom: '12px',
                boxShadow: '0 1px 3px rgba(0,0,0,0.08)',
              }}
            >
              <a href={`/post/${post.id}`} style={{ textDecoration: 'none', color: 'inherit' }}>
                {post.content && <p style={{ margin: '0 0 8px' }}>{post.content}</p>}
                <div style={{ display: 'flex', gap: '16px', color: '#888', fontSize: '0.875rem' }}>
                  <span>❤ {post.like_count}</span>
                  <span>💬 {post.comment_count}</span>
                </div>
              </a>
            </article>
          ))
        )}
      </section>

      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify({
            '@context': 'https://schema.org',
            '@type': 'Person',
            name: user.full_name,
            alternateName: user.username,
            url: `https://nubar.app/user/${user.username}`,
            image: user.avatar_url,
            description: user.bio,
            sameAs: user.website ? [user.website] : [],
          }),
        }}
      />
    </main>
  );
}
