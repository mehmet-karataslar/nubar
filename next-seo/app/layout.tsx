import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: {
    default: 'Nûbar — Platforma Dîjîtal a Çanda Kurdî',
    template: '%s | Nûbar',
  },
  description:
    'Nûbar platforma civakî ya dîjîtal e ji bo civaka Kurdî. Nivîs, wêne, vîdyo û PDF parve bikin, civatan biafirînin û bi Kurdên din re têkilî deynin.',
  keywords: [
    'Nûbar',
    'Kurdish',
    'Kurd',
    'Kurdish social media',
    'Kurdish platform',
    'Kurdî',
    'Kurmanji',
    'Sorani',
    'کوردی',
    'پلاتفۆرمی کوردی',
  ],
  authors: [{ name: 'Nûbar' }],
  openGraph: {
    type: 'website',
    locale: 'ku_TR',
    siteName: 'Nûbar',
    title: 'Nûbar — Platforma Dîjîtal a Çanda Kurdî',
    description:
      'Platforma civakî ya dîjîtal ji bo civaka Kurdî. Parve bike, biafirîne, têkilî deyne.',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Nûbar',
    description: 'Kurdish culture digital platform',
  },
  alternates: {
    languages: {
      'ku': '/',
      'ckb': '/',
      'tr': '/',
      'ar': '/',
      'en': '/',
    },
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ku">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link
          rel="preconnect"
          href="https://fonts.gstatic.com"
          crossOrigin="anonymous"
        />
        <link
          href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Noto+Sans+Arabic:wght@400;500;600;700&display=swap"
          rel="stylesheet"
        />
      </head>
      <body
        style={{
          fontFamily: "'Inter', 'Noto Sans Arabic', sans-serif",
          margin: 0,
          backgroundColor: '#FAF7F0',
          color: '#1a1a1a',
        }}
      >
        {children}
      </body>
    </html>
  );
}
