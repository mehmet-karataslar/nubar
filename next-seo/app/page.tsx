import { supabase, type Post } from '@/lib/supabase';

export const revalidate = 3600; // Revalidate every hour

async function getRecentPosts(): Promise<Post[]> {
  const { data } = await supabase
    .from('posts')
    .select(
      '*, users!posts_user_id_fkey(username, full_name, avatar_url)'
    )
    .eq('is_deleted', false)
    .order('created_at', { ascending: false })
    .limit(20);

  return (data ?? []) as Post[];
}

export default async function HomePage() {
  const posts = await getRecentPosts();

  return (
    <main style={{ maxWidth: '800px', margin: '0 auto', padding: '24px' }}>
      <header style={{ textAlign: 'center', marginBottom: '48px' }}>
        <h1 style={{ fontSize: '2.5rem', color: '#2D6A4F', margin: 0 }}>
          Nûbar
        </h1>
        <p style={{ fontSize: '1.2rem', color: '#666', marginTop: '8px' }}>
          Platforma Dîjîtal a Çanda Kurdî
        </p>
        <p style={{ color: '#888', maxWidth: '600px', margin: '16px auto 0' }}>
          Nivîs, wêne, vîdyo û PDF parve bikin. Civatan biafirînin û bi Kurdên
          din re têkilî deynin.
        </p>
      </header>

      <section>
        <h2 style={{ fontSize: '1.5rem', color: '#2D6A4F', marginBottom: '16px' }}>
          Şandinên Dawî
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
            <a
              href={`/post/${post.id}`}
              style={{ textDecoration: 'none', color: 'inherit' }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px' }}>
                <strong>{post.users?.full_name}</strong>
                <span style={{ color: '#888' }}>
                  @{post.users?.username}
                </span>
              </div>
              {post.content && (
                <p style={{ margin: 0, lineHeight: 1.6 }}>{post.content}</p>
              )}
              <div style={{ display: 'flex', gap: '16px', marginTop: '8px', color: '#888', fontSize: '0.875rem' }}>
                <span>❤ {post.like_count}</span>
                <span>💬 {post.comment_count}</span>
                <span>🔄 {post.repost_count}</span>
              </div>
            </a>
          </article>
        ))}
      </section>

      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify({
            '@context': 'https://schema.org',
            '@type': 'WebSite',
            name: 'Nûbar',
            url: 'https://nubar.app',
            description:
              'Kurdish culture digital platform — share text, photos, videos, and PDFs.',
            inLanguage: ['ku', 'ckb', 'tr', 'ar', 'en'],
          }),
        }}
      />
    </main>
  );
}
