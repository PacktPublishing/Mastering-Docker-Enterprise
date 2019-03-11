from alpine:3.9

RUN adduser -D payment
COPY process.sh /home/payment/process.sh
RUN chown -R payment:payment /home/payment
RUN chmod +x /home/payment/process.sh
USER payment
CMD /home/payment/process.sh