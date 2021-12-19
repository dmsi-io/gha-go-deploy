FROM alpine

LABEL DMSi Software

ADD main main

EXPOSE 8080

CMD ["/main"]