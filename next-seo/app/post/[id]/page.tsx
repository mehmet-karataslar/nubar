type PostPageProps = {
  params: {
    id: string;
  };
};

export default function PostPage({ params }: PostPageProps) {
  return (
    <main>
      <h1>Post SEO Page</h1>
      <p>Post ID: {params.id}</p>
    </main>
  );
}
