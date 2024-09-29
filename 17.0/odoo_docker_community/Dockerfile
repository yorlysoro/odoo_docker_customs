FROM ubuntu:24.04

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG en_US.UTF-8

# Retrieve the target architecture to install the correct wkhtmltopdf package
ARG TARGETARCH

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        node-less \
        npm \
        python3-magic \
        python3-num2words \
        python3-odf \
        python3-pdfminer \
        python3-pip \
        python3-phonenumbers \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        pkg-config \
        cmake \
        libcairo2-dev \
        xz-utils && \
    curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# install latest postgresql-client
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ noble-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update  \
    && apt-get install --no-install-recommends -y postgresql-client

RUN apt update && apt dist-upgrade -y \
&& apt-get install -y npm \
&& npm install -g less less-plugin-clean-css \
&& apt-get install -y node-less


# Install rtlcss (on Debian buster)
RUN npm install -g rtlcss

# Install Dev Depencies
RUN apt update && apt dist-upgrade -y \ 
&& apt-get install -y git python3-pip python3-dev python3-venv libxml2-dev libxslt1-dev \
zlib1g-dev libsasl2-dev libldap2-dev build-essential libssl-dev libffi-dev \
libmysqlclient-dev libjpeg-dev libpq-dev libjpeg8-dev liblcms2-dev libblas-dev libatlas-base-dev -y

# Delete deb cache 
RUN rm -rf /var/lib/apt/lists/*

# Add user odoo
RUN adduser \
--system \
--shell /bin/bash \
--gecos 'Odoo user' \
--group \
--home /opt/odoo \
odoo

# Install Odoo
ENV ODOO_VERSION 17.0
RUN mkdir -p /opt/odoo \
    && chown odoo -R /opt/odoo \
    && mkdir -p /var/opt/src/ \
    && chown odoo -R /var/opt/src/ 
RUN git clone --depth 1 --branch ${ODOO_VERSION} --single-branch https://github.com/OCA/OCB.git /var/opt/src/OCB

COPY odoo /bin/odoo
RUN chown odoo -R /bin/odoo
RUN chown odoo -R /var/opt/src/OCB/odoo-bin
RUN chmod +x /var/opt/src/OCB/odoo-bin
RUN chmod +x /bin/odoo

# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
COPY ./config/odoo.conf /etc/odoo/

RUN chown odoo entrypoint.sh
RUN chmod +x entrypoint.sh

# Set permissions and Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN chown odoo /etc/odoo/odoo.conf \
    && mkdir -p /var/opt/src/oca_addons \
    && chown -R odoo /var/opt/src/oca_addons \
    && mkdir -p /var/opt/src/custom_addons \
    && chown -R odoo /var/opt/src/custom_addons \
    && mkdir -p /var/opt/src/third_party \
    && chown -R odoo /var/opt/src/third_party \
    && mkdir -p /var/lib/odoo \
    && chown -R odoo /var/lib/odoo
VOLUME ["/var/lib/odoo", "/var/opt/src/oca_addons", "/var/opt/src/custom_addons", "/var/opt/src/third_party"]

# Expose Odoo services
EXPOSE 8069 8071 8072 8073 5678

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py
RUN chown odoo /usr/local/bin/wait-for-psql.py
RUN chmod +x /usr/local/bin/wait-for-psql.py

# Set default user when running the container
USER odoo

RUN python3 -m venv /opt/odoo/venv \
    && /opt/odoo/venv/bin/python -m pip install -r /var/opt/src/OCB/requirements.txt \
    && /opt/odoo/venv/bin/python -m pip install psycopg2-binary \
    && /opt/odoo/venv/bin/python -m pip install watchdog ipdb debugpy \
    && /opt/odoo/venv/bin/python -m pip install pysftp pdfminer.six phonenumbers qrcode slugify vobject \
    && /opt/odoo/venv/bin/python -m pip install rlPyCairo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
