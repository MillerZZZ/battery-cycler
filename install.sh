[ ! -d "./bin" ] && mkdir ./bin
[ ! -f "./dependencies/smcFanControl/smc-command/smc" ] && make -C ./dependencies/smcFanControl/smc-command/
cp ./dependencies/smcFanControl/smc-command/smc ./bin/smc
make -C ./dependencies/smcFanControl/smc-command/ clean

bash ./dependencies/battery/update.sh
cp ./dependencies/battery/battery.sh ./bin/battery

cp ./scripts/* ./bin/

cp ./dependencies/volumeshader_bm/vsbm_inline.html ./bin/vsbm_inline.html

chmod +x ./bin/smc
chmod +x ./bin/battery
chmod +x ./bin/cpu_consume.sh

chmod +x ./battery_cycler.sh
