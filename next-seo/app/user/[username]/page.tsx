type UserPageProps = {
  params: {
    username: string;
  };
};

export default function UserPage({ params }: UserPageProps) {
  void params.username;
  return null;
}
