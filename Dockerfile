# Alpine
# BusyBoxをベースに利用して構築されたLinuxディストリビューション　BusyBox→組み込みを目的として作られたとても小さいLinux
# Alpineにapkというパッケージマネージャーがあり、軽量と便利さのバランスがAlpineの採用に繋がっていると思っています。
FROM ruby:alpine3.13

ARG UID

# コンテナ側で生成されたファイルがroot権限で作成されたりするとlocal側での取り扱いがめんどくさい。（sudoしないとファイルを削除できなかったり）
# ローカル側のUID, GIDとコンテナ側でのUID, GIDを揃えられるようにDockerfileやdocker-composeを用意しておくと、このあたりがスムーズに行くようになる
RUN adduser -D app -u ${UID:-1000}

# RUN イメージをビルドすときにコマンドを実行する
RUN apk update \
      && apk add --no-cache gcc make libc-dev g++ mariadb-dev tzdata nodejs~=14 yarn

# 環境変数の設定(本番)
ENV RAILS_ENV=production



# WORKDIR RUN CMD COPYの際の作業ディレクトリ
WORKDIR /myapp

# COPY　Dockerfile を置いたディレクトリ内のファイルしか指定できない
# コピー元は Dockerfile が置かれている場所からの相対パス、コピー先はWORKDIR で指定したパスからの相対パス
COPY Gemfile .
COPY Gemfile.lock .

RUN bundle install


# COPY . /myapp
# シーエイチオウン、ファイルの所有者を変更
# COPY . /myapp 権限はroot:root なので変更
COPY --chown=app:app . /myapp

# yarn installをすることで、package.jsonから/node_modulesを作成
RUN yarn install

COPY entrypoint.sh /usr/bin/

#すべてのユーザーに実行権限を与える
RUN chmod +x /usr/bin/entrypoint.sh

# コンテナ起動時に実行する既定のコマンド
ENTRYPOINT ["entrypoint.sh"]

RUN chmod +x ./bin/webpack
RUN NODE_ENV=production ./bin/webpack

RUN mkdir -p tmp/sockets
RUN mkdir -p tmp/pids

# Fargateではdocker-composeを利用しないので、ボリュームのマウントをするのにVolumeで利用したところをNginxに共有できるようにFargateに設定
VOLUME /myapp/public
VOLUME /myapp/tmp

CMD /bin/sh -c "rm -f tmp/pids/server.pid && bundle exec puma -C config/puma.rb"

# 通信を想定するポート
# EXPOSE 3000

# コンテナ起動時に実行する既定のコマンド
# CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
