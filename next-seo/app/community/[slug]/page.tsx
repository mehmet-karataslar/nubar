type CommunityPageProps = {
  params: {
    slug: string;
  };
};

export default function CommunityPage({ params }: CommunityPageProps) {
  void params.slug;
  return null;
}
