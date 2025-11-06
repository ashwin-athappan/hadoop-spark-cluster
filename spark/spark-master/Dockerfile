FROM spark-base

HEALTHCHECK CMD curl -f http://localhost:8080/ || exit 1

ADD run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 8080
EXPOSE 7077
EXPOSE 22

CMD ["/run.sh"]

