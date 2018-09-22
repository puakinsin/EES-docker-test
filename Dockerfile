FROM debian:jessie
MAINTAINER Elitaco Sdn. Bhd. <rd@elitaco.my>

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            node-less \
            python-gevent \
            python-pip \
            python-renderpm \
            python-support \
            python-watchdog \
            git \
        && curl -o wkhtmltox.deb -SL http://nightly.odoo.com/extra/wkhtmltox-0.12.1.2_linux-jessie-amd64.deb \
        && echo '40e8b906de658a2221b15e4e8cd82565a47d7ee8 wkhtmltox.deb' | sha1sum -c - \
        && dpkg --force-depends -i wkhtmltox.deb \
        && apt-get -y install -f --no-install-recommends \
        && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false npm \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb \
        && pip install psycogreen==1.0

# Install Odoo
ENV EES_VERSION 10.0
ENV EES_RELEASE 20180307
RUN set -x; \
        adduser --system --home=/opt/ees --group ees
        mkdir /var/log/ees
        git clone https://www.github.com/puakinsin/EES-test --depth 1 --branch V10 --single-branch /opt/ees
 #       curl -o odoo.deb -SL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
 #       && echo '836f0fb94aee0d3771cf2188309f6079ee35f83e odoo.deb' | sha1sum -c - \
 #       && dpkg --force-depends -i odoo.deb \
 #       && apt-get update \
 #       && apt-get -y install -f --no-install-recommends \
 #       && rm -rf /var/lib/apt/lists/* odoo.deb

# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
COPY ./ees.conf /etc/ees/
RUN chown ees /etc/ees/ees.conf

# Mount /var/lib/ees to allow restoring filestore and /mnt/extra-addons for users addons
RUN mkdir -p /mnt/extra-addons \
        && chown -R ees /mnt/extra-addons
VOLUME ["/usr/lib/python2.7/dist-packages/odoo", "/var/lib/ees", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071

# Set the default config file
ENV ODOO_RC /etc/ees/ees.conf

# Set default user when running the container
USER ees

ENTRYPOINT ["/entrypoint.sh"]
CMD ["ees"]
