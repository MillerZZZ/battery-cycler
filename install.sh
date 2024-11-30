make -C ./dependencies/smc-command
cp ./dependencies/smc-command/smc /usr/local/bin/smc
chmod +x /usr/local/bin/smc

cp ./dependencies/battery/battery.sh /usr/local/bin/battery
chmod +x /usr/local/bin/battery

chmod +x ./cpu_consume.sh
chmod +x ./battery_cycler.sh
