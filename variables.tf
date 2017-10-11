variable "regions" {
  default = [
    "GRA3",
    "SBG3",
    "BHS3",
    "WAW1",
    "DE1"
  ]
}

variable "vlan_id" {
  default = "42"
}

variable "ssh_key" {
  default = {
    name  = "terra-arnaud-ovh"
    value = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOYsxhRRwC4+uKhJLuoPpNhf1jD97R/S5KnegmCF45QxnSbwfJq4XxBMLc8+BOqP1HLAIRW6HfdZMxkpVVi0aVdYSjJdtBA/9ImceqB0uvXP8Zhsivmr+/u/PB30bUS1/yblOAT62Hxu17KYv79g1FhJa3sJNQ5InzgDOUmLMCYczacMKpVQUFoj92zO3HSe0SXGSBh4++So4rcvD5Dywz6bmMbM/mtzSym95D53RwsJ/9a3CQa3BqIqoRNX/zjGS4C7tpqi1AlwFyBjJzOjqjwDYcTfune22DLnotMX06Salnhp1MZHuhffyUdu8Bkk3RjMiVtTwOECZGr59Ovj5aE2J/xPeDiCWg1J/ois0Zl4TeVipgWL9p/ULBtVS4LpFHO2GKy10rQfW10oYgclR+gfM9SEq3ZuKZmXHieNDUogHCW1oZRi1M3Z7hJEe6C5dmerx02cXb1CBp1OebmrKxQMBt8QtWpnKEE+74GEUbjyRI8oDGOzdTPhkvH6M1o7WyyWmxLwtFkuQkaKxa5lGju+LXJb9tnAyijjpH1h0BldWuEdfiijuIaRieDj1CBDDnn9Ukcjl1eYqGC0KX3M4rq5EIMHwZ8Nb4Lrb6SqUKWz2RYKKWIsT3rJFa3jKiUVzSODM8cGf0rFTKqXihCdqvfkdAYchKli1U6xaEZdl0zw=="
  }
}

variable "flavor" {
  default = "c2-7"
}

variable "image" {
  default = {
    name = "Debian 9"
    user = "debian"
  }
}
