#!/bin/sh

set -e

if [ -z "$1" ]; then
	echo "Path to metrics file needed"
	exit 1
fi

if [ ! -f "$1" ]; then
	echo "File doesn't exist"
	exit 1
fi

METRICS_FILE="$1"
readonly METRICS_FILE

get_stats() {
	metrics=$1
	min=$(echo "${metrics}" | sort -n | head -n1)
	max=$(echo "${metrics}" | sort -n | tail -n1)
	mean=$(echo "${metrics}" | awk '{sum+=$1} END {print sum/NR}')
	std=$(echo "${metrics}" | awk '{x[NR]=$1; sum+=$1; sumsq+=$1*$1} END {
					mean=sum/NR;
					stddev=sqrt(sumsq/NR - mean^2);
					print stddev;
				}')
	median=$(echo "${metrics}" | sort -n | awk '{
							a[NR] = $1
						}
						END {
						  if (NR % 2 == 1)
						    print a[(NR + 1) / 2]
						  else
						    print (a[NR/2] + a[NR/2 + 1]) / 2
						}')
	printf '%s,%s,%s,%s,%s' "${max}" "${mean}" "${min}" "${std}" "${median}"
}

content_pull_results=$(grep 'content-pull' "${METRICS_FILE}" | sed 's|content-pull: ||')
service_pull_results=$(grep 'service-pull' "${METRICS_FILE}" | sed 's|service-pull: ||')
upload_content_results=$(grep 'upload-content' "${METRICS_FILE}" | sed 's|upload-content: ||')
upload_service_results=$(grep 'upload-service' "${METRICS_FILE}" | sed 's|upload-service: ||')
service_provide_results=$(grep 'service-provide' "${METRICS_FILE}" | sed 's|service-provide: ||')
content_provide_results=$(grep 'content-provide' "${METRICS_FILE}" | sed 's|content-provide: ||')
wait_peers_content_results=$(grep 'wait-peers-content' "${METRICS_FILE}" | sed 's|wait-peers-content: ||')
wait_peers_service_results=$(grep 'wait-peers-service' "${METRICS_FILE}" | sed 's|wait-peers-service: ||')
publish_content_results=$(grep 'publish-content' "${METRICS_FILE}" | sed 's|publish-content: ||')
publish_service_results=$(grep 'publish-service' "${METRICS_FILE}" | sed 's|publish-service: ||')
unpin_results=$(grep 'unpin' "${METRICS_FILE}" | sed 's|unpin: ||')
total_results=$(awk '
/^Run results:/ { if (NR > 1) print sum; sum = 0; next }
/^[a-zA-Z0-9-]+: [0-9.]+$/ { sum += $2 }
END { print sum }
' "${METRICS_FILE}")

csv_file=$(echo "${METRICS_FILE}" | sed 's|\.log|\.csv|')
printf ',max,mean,min,std,median\ncontent-pull,' >"${csv_file}"
get_stats "${content_pull_results}" >>"${csv_file}"
printf '\nservice-pull,' >>"${csv_file}"
get_stats "${service_pull_results}" >>"${csv_file}"
printf '\nupload-content,' >>"${csv_file}"
get_stats "${upload_content_results}" >>"${csv_file}"
printf '\nupload-service,' >>"${csv_file}"
get_stats "${upload_service_results}" >>"${csv_file}"
printf '\nservice-provide,' >>"${csv_file}"
get_stats "${service_provide_results}" >>"${csv_file}"
printf '\ncontent-provide,' >>"${csv_file}"
get_stats "${content_provide_results}" >>"${csv_file}"
printf '\nwait-peers-content,' >>"${csv_file}"
get_stats "${wait_peers_content_results}" >>"${csv_file}"
printf '\nwait-peers-service,' >>"${csv_file}"
get_stats "${wait_peers_service_results}" >>"${csv_file}"
printf '\npublish-content,' >>"${csv_file}"
get_stats "${publish_content_results}" >>"${csv_file}"
printf '\npublish-service,' >>"${csv_file}"
get_stats "${publish_service_results}" >>"${csv_file}"
printf '\nunpin,' >>"${csv_file}"
get_stats "${unpin_results}" >>"${csv_file}"
printf '\ntotal,' >>"${csv_file}"
get_stats "${total_results}" >>"${csv_file}"
