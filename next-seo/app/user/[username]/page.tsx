type UserPageProps = {
  params: {
    username: string;
  };
};

export default function UserPage({ params: _params }: UserPageProps) {
  return (
    <main>
      <h1>User SEO Page</h1>
      <p>Username: {_params.username}</p>
    </main>
  );
}
