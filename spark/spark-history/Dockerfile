FROM spark-base

HEALTHCHECK CMD curl -f http://localhost:18080/ || exit 1

ADD run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 18080
EXPOSE 22

CMD ["/run.sh"]

