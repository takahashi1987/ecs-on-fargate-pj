# Alpine
# BusyBoxをベースに利用して構築されたLinuxディストリビューション　BusyBox→組み込みを目的として作られたとても小さいLinux
# Alpineにapkというパッケージマネージャーがあり、軽量と便利さのバランスがAlpineの採用に繋がっていると思っています。
FROM ruby:alpine3.13

# RUN イメージをビルドすときにコマンドを実行する
RUN apk update \
      && apk add --no-cache gcc make libc-dev g++ mariadb-dev tzdata nodejs~=14 yarn

# WORKDIR RUN CMD COPYの際の作業ディレクトリ
WORKDIR /myapp

# COPY　Dockerfile を置いたディレクトリ内のファイルしか指定できない
# コピー元は Dockerfile が置かれている場所からの相対パス、コピー先はWORKDIR で指定したパスからの相対パス
COPY Gemfile .
COPY Gemfile.lock .

RUN bundle install

COPY . /myapp

COPY entrypoint.sh /usr/bin/

#すべてのユーザーに実行権限を与える
RUN chmod +x /usr/bin/entrypoint.sh

# コンテナ起動時に実行する既定のコマンド
ENTRYPOINT ["entrypoint.sh"]

# 通信を想定するポート
EXPOSE 3000

# コンテナ起動時に実行する既定のコマンド
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
