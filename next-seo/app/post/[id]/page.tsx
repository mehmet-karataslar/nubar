type PostPageProps = {
  params: {
    id: string;
  };
};

export default function PostPage({ params: _params }: PostPageProps) {
  return (
    <main>
      <h1>Post SEO Page</h1>
      <p>Post ID: {_params.id}</p>
    </main>
  );
}
