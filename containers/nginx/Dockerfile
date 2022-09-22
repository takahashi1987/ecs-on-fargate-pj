FROM nginx:alpine

# インクルード用のディレクトリ内を削除
RUN rm -f /etc/nginx/conf.d/*

# Nginxの設定ファイルをコンテナにコピー
# ADD nginx.conf /etc/nginx/conf.d/myapp.conf

# docker buildのときは以下のコメントをはずす
# 変更しないとbuildで引っかかる
# docker buildとdocker-composeでのファイルパスに違いがあるためエラーになるのでこのようにしています。
ADD /containers/nginx/nginx.conf /etc/nginx/conf.d/myapp.conf

# ビルド完了後にNginxを起動
CMD /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
