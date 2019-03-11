FROM nginx:1.14-alpine

COPY nginx.conf /etc/nginx/nginx.conf

# Added an entrypoint.sh. 
# Need to add sleep command before starting NGINX services to avoid a DNS problem.
COPY entrypoint.sh .
CMD ./entrypoint.sh