sudo python /rpicluster/config/config.py &
cd /rpicluster/config
output=`python -c 'from list_leases import *; print " ".join(getMachines())'`
for i in ${output[@]}
do
    fab config_ip -u pi -H "$i" -p "raspberry"
done
sudo reboot -h now
