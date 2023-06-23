data "aws_route53_zone" "dns-main" {
    name = "cloud-adrian.click"
}

resource "aws_route53_record" "www" {
    type = "CNAME"
    name = "www.${data.aws_route53_zone.dns-main.name}"
    ttl = 300
    records = [aws_lb.lb-main.dns_name]
    zone_id = data.aws_route53_zone.dns-main.zone_id
}
