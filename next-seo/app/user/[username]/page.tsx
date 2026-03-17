type UserPageProps = {
  params: {
    username: string;
  };
};

export default function UserPage({ params }: UserPageProps) {
  return (
    <main>
      <h1>User SEO Page</h1>
      <p>Username: {params.username}</p>
    </main>
  );
}
