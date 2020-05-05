role GPGME::LinkedList does Iterable
{
    method list(--> Seq)
    {
        gather
        {
            loop (my $i = self; $i; $i = $i.next)
            {
                take $i;
            }
        }
    }
}
