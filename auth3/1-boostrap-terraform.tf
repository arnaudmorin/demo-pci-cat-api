# Configure the OpenStack Provider
# It will read info from env OS_xxx
provider "openstack" {
  user_name = "nUv3vY3TjWDV"
  tenant_name = "6837909462521441"
  tenant_id = "0d899a6f76d74760a06919233ed0ec51"
  password  = "pass"
  auth_url  = "https://auth.cloud.ovh.net"
  domain_name = "Default"
}

#
# SSH key
#
resource "openstack_compute_keypair_v2" "keypairs" {
  name          = "cat-arnaud-ovh"
  region        = "SBG3"
  public_key    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOYsxhRRwC4+uKhJLuoPpNhf1jD97R/S5KnegmCF45QxnSbwfJq4XxBMLc8+BOqP1HLAIRW6HfdZMxkpVVi0aVdYSjJdtBA/9ImceqB0uvXP8Zhsivmr+/u/PB30bUS1/yblOAT62Hxu17KYv79g1FhJa3sJNQ5InzgDOUmLMCYczacMKpVQUFoj92zO3HSe0SXGSBh4++So4rcvD5Dywz6bmMbM/mtzSym95D53RwsJ/9a3CQa3BqIqoRNX/zjGS4C7tpqi1AlwFyBjJzOjqjwDYcTfune22DLnotMX06Salnhp1MZHuhffyUdu8Bkk3RjMiVtTwOECZGr59Ovj5aE2J/xPeDiCWg1J/ois0Zl4TeVipgWL9p/ULBtVS4LpFHO2GKy10rQfW10oYgclR+gfM9SEq3ZuKZmXHieNDUogHCW1oZRi1M3Z7hJEe6C5dmerx02cXb1CBp1OebmrKxQMBt8QtWpnKEE+74GEUbjyRI8oDGOzdTPhkvH6M1o7WyyWmxLwtFkuQkaKxa5lGju+LXJb9tnAyijjpH1h0BldWuEdfiijuIaRieDj1CBDDnn9Ukcjl1eYqGC0KX3M4rq5EIMHwZ8Nb4Lrb6SqUKWz2RYKKWIsT3rJFa3jKiUVzSODM8cGf0rFTKqXihCdqvfkdAYchKli1U6xaEZdl0zw=="
}

