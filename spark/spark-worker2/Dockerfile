FROM spark-base

HEALTHCHECK CMD curl -f http://localhost:8081/ || exit 1

ADD run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 8081
EXPOSE 22

CMD ["/run.sh"]

