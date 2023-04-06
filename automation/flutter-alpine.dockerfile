FROM alpine:3.14

# Install dependencies
RUN apk update && apk add --no-cache \
    bash \
    git \
    curl \
    unzip \
    libstdc++ \
    lib32stdc++6 \
    libgcc \
    lib32gcc1 \
    libc6-i386 \
    lib32z1 \
    lib32ncurses6 \
    libbz2 \
    openjdk8-jre \
    openssh-client \
    python3 \
    python3-dev \
    py3-pip \
    xz

# Install Flutter SDK
ENV FLUTTER_VERSION=2.8.1
ENV FLUTTER_HOME=/usr/local/flutter
ENV PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH"
RUN curl -L https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz | tar -C /usr/local/ -xJ \
    && flutter config --no-analytics \
    && flutter precache \
    && flutter doctor -v

# Install Dart SDK
ENV DART_VERSION=2.14.4
ENV DART_HOME=/usr/local/dart-sdk
ENV PATH="$DART_HOME/bin:$PATH"
RUN curl -L https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/sdk/dartsdk-linux-x64-release.zip -o /tmp/dart-sdk.zip \
    && unzip /tmp/dart-sdk.zip -d /usr/local \
    && rm /tmp/dart-sdk.zip

# Install VS Code Server
ENV VSCODE_SERVER_VERSION=3.11.0
RUN curl -L https://github.com/cdr/code-server/releases/download/v${VSCODE_SERVER_VERSION}/code-server-${VSCODE_SERVER_VERSION}-linux-x86_64.tar.gz | tar -C /usr/local/ -xz \
    && mv /usr/local/code-server-${VSCODE_SERVER_VERSION}-linux-x86_64 /usr/local/code-server \
    && ln -s /usr/local/code-server/bin/code-server /usr/local/bin/code-server

# Set up VS Code Server
RUN mkdir -p /home/coder/project
ENV USER=coder
ENV HOME=/home/coder
ENV PASSWORD=password
RUN addgroup ${USER} \
    && adduser -G ${USER} -s /bin/sh -D ${USER} \
    && echo "${USER}:${PASSWORD}" | chpasswd \
    && chown -R ${USER}:${USER} ${HOME} \
    && echo "export PATH=$PATH" >> /home/coder/.bashrc \
    && echo "flutter config --no-analytics" >> /home/coder/.bashrc \
    && echo "flutter precache" >> /home/coder/.bashrc \
    && echo "flutter doctor -v" >> /home/coder/.bashrc

EXPOSE 8080
WORKDIR /home/coder/project
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "password"]


// docker build -t vscode-flutter .
// docker run -d --name vscode-flutter -p 8080:8080 vscode-flutter
// update flutter and vscode versions before running
