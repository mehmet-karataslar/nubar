import type { Metadata } from 'next';
import { notFound } from 'next/navigation';
import { supabase, type Community, type Post } from '@/lib/supabase';

export const revalidate = 3600;

interface PageProps {
  params: Promise<{ slug: string }>;
}

async function getCommunity(slug: string): Promise<Community | null> {
  const { data } = await supabase
    .from('communities')
    .select('*')
    .eq('slug', slug)
    .maybeSingle();

  return data as Community | null;
}

async function getCommunityPosts(communityId: string): Promise<Post[]> {
  const { data } = await supabase
    .from('posts')
    .select('*, users!posts_user_id_fkey(username, full_name, avatar_url)')
    .eq('community_id', communityId)
    .eq('is_deleted', false)
    .order('created_at', { ascending: false })
    .limit(20);

  return (data ?? []) as Post[];
}

export async function generateStaticParams() {
  const { data } = await supabase.from('communities').select('slug').limit(100);
  return (data ?? []).map((c) => ({ slug: c.slug }));
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { slug } = await params;
  const community = await getCommunity(slug);

  if (!community) {
    return { title: 'Community Not Found' };
  }

  const title = community.name;
  const description =
    community.description ??
    `${community.name} — a community on Nûbar with ${community.member_count} members`;

  return {
    title,
    description,
    openGraph: {
      title: `${title} | Nûbar`,
      description,
      type: 'website',
      images: community.banner_url ? [community.banner_url] : [],
    },
    twitter: {
      card: 'summary_large_image',
      title,
      description,
    },
  };
}

export default async function CommunityPage({ params }: PageProps) {
  const { slug } = await params;
  const community = await getCommunity(slug);

  if (!community) {
    notFound();
  }

  const posts = await getCommunityPosts(community.id);

  return (
    <main style={{ maxWidth: '800px', margin: '0 auto', padding: '24px' }}>
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
        {community.banner_url && (
          <img
            src={community.banner_url}
            alt={community.name}
            style={{ width: '100%', height: '200px', objectFit: 'cover', borderRadius: '8px', marginBottom: '16px' }}
          />
        )}
        {community.avatar_url && (
          <img
            src={community.avatar_url}
            alt={community.name}
            width={80}
            height={80}
            style={{ borderRadius: '50%', marginBottom: '12px' }}
          />
        )}
        <h1 style={{ fontSize: '2rem', color: '#2D6A4F', margin: '0 0 8px' }}>
          {community.name}
        </h1>
        {community.description && (
          <p style={{ color: '#666', maxWidth: '500px', margin: '0 auto 16px' }}>
            {community.description}
          </p>
        )}
        <div style={{ display: 'flex', justifyContent: 'center', gap: '24px', color: '#888' }}>
          <span><strong>{community.member_count}</strong> endam</span>
          <span><strong>{community.post_count}</strong> şandin</span>
        </div>
      </header>

      <section>
        <h2 style={{ fontSize: '1.25rem', color: '#2D6A4F', marginBottom: '12px' }}>
          Şandinên Civatê
        </h2>

        {posts.map((post) => (
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
              <div style={{ display: 'flex', gap: '8px', marginBottom: '8px' }}>
                <strong>{post.users?.full_name}</strong>
                <span style={{ color: '#888' }}>@{post.users?.username}</span>
              </div>
              {post.content && <p style={{ margin: 0 }}>{post.content}</p>}
            </a>
          </article>
        ))}
      </section>

      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify({
            '@context': 'https://schema.org',
            '@type': 'Organization',
            name: community.name,
            description: community.description,
            url: `https://nubar.app/community/${community.slug}`,
            memberOf: {
              '@type': 'WebSite',
              name: 'Nûbar',
            },
          }),
        }}
      />
    </main>
  );
}
