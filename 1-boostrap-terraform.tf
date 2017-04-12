# Configure the OpenStack Provider
# It will read info from env OS_xxx
provider "openstack" {
}

# Create a web server
resource "openstack_compute_instance_v2" "backends" {
  name          = "${format("backend-%02d", count.index+1)}"
  count         = "${var.backends}"
  region        = "${var.region}"
  image_name    = "Debian 8"
  key_pair      = "arnaud-ovh"
  flavor_name   = "c2-7"
  network       = { name = "Ext-Net" }
  connection    = { user = "debian" }
  user_data     = "${file("backend.yaml")}"
}

# Create template for frontend
data "template_file" "frontend_user_data" {
  template = "${file("frontend.yaml.tpl")}"
  vars {
    nodes = "${join("\n", formatlist("    server %s %s:5000", openstack_compute_instance_v2.backends.*.name, openstack_compute_instance_v2.backends.*.access_ip_v4))}"
  }
}

# Create a frontend server
resource "openstack_compute_instance_v2" "frontend" {
  name          = "frontend"
  region        = "${var.region}"
  image_name    = "Debian 8"
  key_pair      = "arnaud-ovh"
  flavor_name   = "c2-7"
  network       = { name = "Ext-Net" }
  connection    = { user = "debian" }
  user_data     = "${data.template_file.frontend_user_data.rendered}"
}

output "backends" {
  value = "${join("\n", formatlist("http://%s:5000", openstack_compute_instance_v2.backends.*.access_ip_v4))}"
}

output "frontend" {
  value = "${format("http://%s", openstack_compute_instance_v2.frontend.access_ip_v4)}"
}

