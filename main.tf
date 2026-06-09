# make sure create unambiguous object definition for xc smsv2 site
# in this case for azure linux host only!!!
resource "random_id" "xc-mcn-random-id" {
  byte_length = 2
}

