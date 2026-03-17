type PostPageProps = {
  params: {
    id: string;
  };
};

export default function PostPage({ params }: PostPageProps) {
  void params.id;
  return null;
}
