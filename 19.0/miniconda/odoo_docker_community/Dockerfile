FROM debian:13

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

ENV LANG=en_US.UTF-8
ARG TARGETARCH

# Install required dependencies and tools
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
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
    xz-utils \
    git \
    python3-dev \
    python3-venv \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libsasl2-dev \
    libldap2-dev \
    build-essential \
    libffi-dev \
    libmariadb-dev \  
    libjpeg-dev \
    libpq-dev \
    liblcms2-dev \
    libblas-dev \
    liblapack-dev \
    && curl -o libssl1.1.deb -sSL http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.1_1.1.1w-0+deb11u4_amd64.deb \ 
    && apt install -y --no-install-recommends ./libssl1.1.deb \
    && rm -f libssl1.1.deb \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.bullseye_amd64.deb \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && npm install -g less less-plugin-clean-css rtlcss \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb \
    && apt-get clean

# Install PostgreSQL client
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ trixie-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update \
    && apt-get install --no-install-recommends -y postgresql-client \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Final cleanup
RUN apt update && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y && apt clean && apt autoclean

# Create odoo user
RUN adduser --system --shell /bin/bash --gecos 'Odoo user' --group --home /opt/odoo odoo


# Install Odoo
ENV ODOO_VERSION=19.0
ENV ODOO_URL=https://github.com/odoo/odoo.git
RUN mkdir -p /opt/odoo \
    && chown odoo -R /opt/odoo \
    && mkdir -p /var/opt/src/ \
    && chown odoo -R /var/opt/src/ 
RUN git clone --depth 1 --branch ${ODOO_VERSION} --single-branch ${ODOO_URL} /var/opt/src/odoo

COPY odoo /bin/odoo
RUN chown odoo -R /bin/odoo
RUN chown odoo -R /var/opt/src/odoo/odoo-bin
RUN chmod +x /var/opt/src/odoo/odoo-bin
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
ENV ODOO_RC=/etc/odoo/odoo.conf

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py
RUN chown odoo /usr/local/bin/wait-for-psql.py
RUN chmod +x /usr/local/bin/wait-for-psql.py

#Fix permissions on /opt/odoo folder, for odoo user and odoo filestore access
RUN chown odoo:odoo -R /opt/odoo
RUN chmod -R u+rwx /opt/odoo

# Install Miniconda and create Python 3.11 environment recommended for Odoo 19.0
RUN curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p /opt/conda \
    && rm -f /tmp/miniconda.sh \
    && /opt/conda/bin/conda init \
    && /opt/conda/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main \
    && /opt/conda/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r \
    && /opt/conda/bin/conda create -y -p /opt/conda/envs/odoo311 python=3.11 \
    && /opt/conda/bin/conda clean -afy \
    && chown -R odoo:odoo /opt/conda

# Set default user when running the container
USER odoo

RUN python3 -m venv /opt/odoo/venv \
    && /opt/odoo/venv/bin/python -m pip install -r /var/opt/src/odoo/requirements.txt \
    && /opt/odoo/venv/bin/python -m pip install psycopg2-binary \
    && /opt/odoo/venv/bin/python -m pip install watchdog ipdb debugpy pydevd \
    && /opt/odoo/venv/bin/python -m pip install pysftp pdfminer.six phonenumbers qrcode slugify vobject \
    && /opt/odoo/venv/bin/python -m pip install rlPyCairo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]