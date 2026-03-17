type CommunityPageProps = {
  params: {
    slug: string;
  };
};

export default function CommunityPage({ params: _params }: CommunityPageProps) {
  return (
    <main>
      <h1>Community SEO Page</h1>
      <p>Community Slug: {_params.slug}</p>
    </main>
  );
}
