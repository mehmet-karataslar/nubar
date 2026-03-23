import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Sayfa nehat dîtin — Nûbar',
  description: 'Ev rûpel nehat dîtin. Ji kerema xwe vegerin ser rûpela sereke.',
};

export default function NotFound() {
  return (
    <main
      style={{
        maxWidth: '600px',
        margin: '0 auto',
        padding: '80px 24px',
        textAlign: 'center',
      }}
    >
      <h1
        style={{
          fontSize: '6rem',
          fontWeight: 'bold',
          color: '#2D6A4F',
          margin: '0 0 8px',
          lineHeight: 1,
        }}
      >
        404
      </h1>
      <h2
        style={{
          fontSize: '1.5rem',
          color: '#333',
          margin: '0 0 16px',
        }}
      >
        Sayfa nehat dîtin
      </h2>
      <p style={{ color: '#888', marginBottom: '32px', lineHeight: 1.6 }}>
        Ev rûpel nehat dîtin an jî hatiye guhertin. Ji kerema xwe vegerin ser
        rûpela sereke.
      </p>
      <a
        href="/"
        style={{
          display: 'inline-block',
          backgroundColor: '#2D6A4F',
          color: '#fff',
          padding: '12px 32px',
          borderRadius: '8px',
          textDecoration: 'none',
          fontWeight: 600,
          transition: 'opacity 0.2s',
        }}
      >
        ← Vegere Nûbar
      </a>

      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify({
            '@context': 'https://schema.org',
            '@type': 'WebPage',
            name: '404 — Page Not Found',
            url: 'https://nubar.app/404',
            isPartOf: {
              '@type': 'WebSite',
              name: 'Nûbar',
              url: 'https://nubar.app',
            },
          }),
        }}
      />
    </main>
  );
}
