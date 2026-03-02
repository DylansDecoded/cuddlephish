import sys
from mitmproxy import ctx


class InjectClientIP:
    def __init__(self):
        self.victim_ip = ""
        self.vps_ip = ""

    def load(self, loader):
        loader.add_option(
            name="victim_ip",
            typespec=str,
            default="",
            help="Victim's real client IP to inject into forwarding headers",
        )
        loader.add_option(
            name="vps_ip",
            typespec=str,
            default="",
            help="VPS egress IP to use as the second hop in the X-Forwarded-For chain",
        )

    def configure(self, updates):
        if "victim_ip" in updates:
            self.victim_ip = ctx.options.victim_ip
        if "vps_ip" in updates:
            self.vps_ip = ctx.options.vps_ip

    def request(self, flow):
        if not self.victim_ip:
            return
        if self.vps_ip:
            flow.request.headers["X-Forwarded-For"] = f"{self.victim_ip}, {self.vps_ip}"
        else:
            flow.request.headers["X-Forwarded-For"] = self.victim_ip
        flow.request.headers["True-Client-IP"] = self.victim_ip
        flow.request.headers["X-Real-IP"] = self.victim_ip


addons = [InjectClientIP()]
