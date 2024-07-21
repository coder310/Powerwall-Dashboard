# DDL
# USE powerwall
CREATE DATABASE powerwall
CREATE RETENTION POLICY raw ON powerwall duration 3d replication 1
ALTER RETENTION POLICY autogen ON powerwall duration 0s
CREATE RETENTION POLICY strings ON powerwall duration 0s replication 1
CREATE RETENTION POLICY pwtemps ON powerwall duration 0s replication 1
CREATE RETENTION POLICY vitals ON powerwall duration 0s replication 1
CREATE RETENTION POLICY kwh ON powerwall duration INF replication 1
CREATE RETENTION POLICY daily ON powerwall duration INF replication 1
CREATE RETENTION POLICY monthly ON powerwall duration INF replication 1
CREATE RETENTION POLICY grid ON powerwall duration INF replication 1
CREATE RETENTION POLICY pod ON powerwall duration INF replication 1
CREATE RETENTION POLICY alerts ON powerwall duration INF replication 1
CREATE CONTINUOUS QUERY cq_autogen ON powerwall BEGIN SELECT mean(home) AS home, mean(solar) AS solar, mean(from_pw) AS from_pw, mean(to_pw) AS to_pw, mean(from_grid) AS from_grid, mean(to_grid) AS to_grid, last(percentage) AS percentage INTO powerwall.autogen.:MEASUREMENT FROM (SELECT load_instant_power AS home, solar_instant_power AS solar, abs((1+battery_instant_power/abs(battery_instant_power))*battery_instant_power/2) AS from_pw, abs((1-battery_instant_power/abs(battery_instant_power))*battery_instant_power/2) AS to_pw, abs((1+site_instant_power/abs(site_instant_power))*site_instant_power/2) AS from_grid, abs((1-site_instant_power/abs(site_instant_power))*site_instant_power/2) AS to_grid, percentage FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_autogen_current ON powerwall BEGIN SELECT mean(home) AS home_current, mean(solar) AS solar_current, mean(pw) AS pw_current, mean(grid) AS grid_current INTO powerwall.autogen.:MEASUREMENT FROM (SELECT load_instant_total_current AS home, solar_instant_total_current AS solar, battery_instant_total_current AS pw, site_instant_total_current AS grid FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_autogen_voltage ON powerwall BEGIN SELECT mean(home) AS home_voltage, mean(solar) AS solar_voltage, mean(pw) AS pw_voltage, mean(grid) AS grid_voltage INTO powerwall.autogen.:MEASUREMENT FROM (SELECT load_instant_average_voltage AS home, solar_instant_average_voltage AS solar, battery_instant_average_voltage AS pw, site_instant_average_voltage AS grid FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_kwh ON powerwall RESAMPLE EVERY 1m BEGIN SELECT integral(home)/1000/3600 AS home, integral(solar)/1000/3600 AS solar, integral(from_pw)/1000/3600 AS from_pw, integral(to_pw)/1000/3600 AS to_pw, integral(from_grid)/1000/3600 AS from_grid, integral(to_grid)/1000/3600 AS to_grid INTO powerwall.kwh.:MEASUREMENT FROM autogen.http GROUP BY time(1h), month, year tz('America/Los_Angeles') END
CREATE CONTINUOUS QUERY cq_daily ON powerwall RESAMPLE EVERY 1h BEGIN SELECT sum(home) AS home, sum(solar) AS solar, sum(from_pw) AS from_pw, sum(to_pw) AS to_pw, sum(from_grid) AS from_grid, sum(to_grid) AS to_grid INTO powerwall.daily.:MEASUREMENT FROM powerwall.kwh.http GROUP BY time(1d), month, year tz('America/Los_Angeles') END 
CREATE CONTINUOUS QUERY cq_monthly ON powerwall RESAMPLE EVERY 1h BEGIN SELECT sum(home) AS home, sum(solar) AS solar, sum(from_pw) AS from_pw, sum(to_pw) AS to_pw, sum(from_grid) AS from_grid, sum(to_grid) AS to_grid INTO powerwall.monthly.:MEASUREMENT FROM powerwall.daily.http GROUP BY time(365d), month, year END
CREATE CONTINUOUS QUERY cq_pw_temps ON powerwall BEGIN SELECT mean(PW1_temp) AS PW1_temp, mean(PW2_temp) AS PW2_temp, mean(PW3_temp) AS PW3_temp, mean(PW4_temp) AS PW4_temp, mean(PW5_temp) AS PW5_temp, mean(PW6_temp) AS PW6_temp INTO powerwall.pwtemps.:MEASUREMENT FROM (SELECT PW1_temp, PW2_temp, PW3_temp, PW4_temp, PW5_temp, PW6_temp FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_pw_tempsb ON powerwall BEGIN SELECT mean(PW7_temp) AS PW7_temp, mean(PW8_temp) AS PW8_temp, mean(PW9_temp) AS PW9_temp, mean(PW10_temp) AS PW10_temp, mean(PW11_temp) AS PW11_temp, mean(PW12_temp) AS PW12_temp INTO powerwall.pwtemps.:MEASUREMENT FROM (SELECT PW7_temp, PW8_temp, PW9_temp, PW10_temp, PW11_temp, PW12_temp FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_strings ON powerwall BEGIN SELECT mean(A_Current) AS A_Current, mean(A_Power) AS A_Power, mean(A_Voltage) AS A_Voltage, mean(B_Current) AS B_Current, mean(B_Power) AS B_Power, mean(B_Voltage) AS B_Voltage, mean(C_Current) AS C_Current, mean(C_Power) AS C_Power, mean(C_Voltage) AS C_Voltage, mean(D_Current) AS D_Current, mean(D_Power) AS D_Power, mean(D_Voltage) AS D_Voltage INTO powerwall.strings.:MEASUREMENT FROM (SELECT A_Current, A_Power, A_Voltage, B_Current, B_Power, B_Voltage, C_Current, C_Power, C_Voltage, D_Current, D_Power, D_Voltage FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_strings1 ON powerwall BEGIN SELECT mean(A1_Current) AS A1_Current, mean(A1_Power) AS A1_Power, mean(A1_Voltage) AS A1_Voltage, mean(B1_Current) AS B1_Current, mean(B1_Power) AS B1_Power, mean(B1_Voltage) AS B1_Voltage, mean(C1_Current) AS C1_Current, mean(C1_Power) AS C1_Power, mean(C1_Voltage) AS C1_Voltage, mean(D1_Current) AS D1_Current, mean(D1_Power) AS D1_Power, mean(D1_Voltage) AS D1_Voltage INTO powerwall.strings.:MEASUREMENT FROM (SELECT A1_Current, A1_Power, A1_Voltage, B1_Current, B1_Power, B1_Voltage, C1_Current, C1_Power, C1_Voltage, D1_Current, D1_Power, D1_Voltage FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_strings2 ON powerwall BEGIN SELECT mean(A2_Current) AS A2_Current, mean(A2_Power) AS A2_Power, mean(A2_Voltage) AS A2_Voltage, mean(B2_Current) AS B2_Current, mean(B2_Power) AS B2_Power, mean(B2_Voltage) AS B2_Voltage, mean(C2_Current) AS C2_Current, mean(C2_Power) AS C2_Power, mean(C2_Voltage) AS C2_Voltage, mean(D2_Current) AS D2_Current, mean(D2_Power) AS D2_Power, mean(D2_Voltage) AS D2_Voltage INTO powerwall.strings.:MEASUREMENT FROM (SELECT A2_Current, A2_Power, A2_Voltage, B2_Current, B2_Power, B2_Voltage, C2_Current, C2_Power, C2_Voltage, D2_Current, D2_Power, D2_Voltage FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_strings3 ON powerwall BEGIN SELECT mean(A3_Current) AS A3_Current, mean(A3_Power) AS A3_Power, mean(A3_Voltage) AS A3_Voltage, mean(B3_Current) AS B3_Current, mean(B3_Power) AS B3_Power, mean(B3_Voltage) AS B3_Voltage, mean(C3_Current) AS C3_Current, mean(C3_Power) AS C3_Power, mean(C3_Voltage) AS C3_Voltage, mean(D3_Current) AS D3_Current, mean(D3_Power) AS D3_Power, mean(D3_Voltage) AS D3_Voltage INTO powerwall.strings.:MEASUREMENT FROM (SELECT A3_Current, A3_Power, A3_Voltage, B3_Current, B3_Power, B3_Voltage, C3_Current, C3_Power, C3_Voltage, D3_Current, D3_Power, D3_Voltage FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_inverters ON powerwall BEGIN SELECT mean(Inverter1) AS Inverter1, mean(Inverter2) AS Inverter2, mean(Inverter3) AS Inverter3, mean(Inverter4) AS Inverter4 INTO powerwall.strings.:MEASUREMENT FROM (SELECT A_Power+B_Power+C_Power+D_Power AS Inverter1, A1_Power+B1_Power+C1_Power+D1_Power AS Inverter2, A2_Power+B2_Power+C2_Power+D2_Power AS Inverter3, A3_Power+B3_Power+C3_Power+D3_Power AS Inverter4 FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_vitals1 ON powerwall BEGIN SELECT mean(PW1_PINV_Fout) AS PW1_PINV_Fout, mean(PW2_PINV_Fout) AS PW2_PINV_Fout, mean(PW3_PINV_Fout) AS PW3_PINV_Fout, mean(PW4_PINV_Fout) AS PW4_PINV_Fout, mean(PW5_PINV_Fout) AS PW5_PINV_Fout, mean(PW6_PINV_Fout) AS PW6_PINV_Fout INTO powerwall.vitals.:MEASUREMENT FROM (SELECT PW1_PINV_Fout, PW2_PINV_Fout, PW3_PINV_Fout, PW4_PINV_Fout, PW5_PINV_Fout, PW6_PINV_Fout  FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_vitals1b ON powerwall BEGIN SELECT mean(PW7_PINV_Fout) AS PW7_PINV_Fout, mean(PW8_PINV_Fout) AS PW8_PINV_Fout, mean(PW9_PINV_Fout) AS PW9_PINV_Fout, mean(PW10_PINV_Fout) AS PW10_PINV_Fout, mean(PW11_PINV_Fout) AS PW11_PINV_Fout, mean(PW12_PINV_Fout) AS PW12_PINV_Fout INTO powerwall.vitals.:MEASUREMENT FROM (SELECT PW7_PINV_Fout, PW8_PINV_Fout, PW9_PINV_Fout, PW10_PINV_Fout, PW11_PINV_Fout, PW12_PINV_Fout  FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_vitals2 ON powerwall BEGIN SELECT mean(ISLAND_FreqL1_Load) AS ISLAND_FreqL1_Load, mean(ISLAND_FreqL2_Load) AS ISLAND_FreqL2_Load, mean(ISLAND_FreqL3_Load) AS ISLAND_FreqL3_Load, mean(ISLAND_FreqL1_Main) AS ISLAND_FreqL1_Main, mean(ISLAND_FreqL2_Main) AS ISLAND_FreqL2_Main, mean(ISLAND_FreqL3_Main) AS ISLAND_FreqL3_Main INTO powerwall.vitals.:MEASUREMENT FROM (SELECT ISLAND_FreqL1_Load, ISLAND_FreqL2_Load, ISLAND_FreqL3_Load, ISLAND_FreqL1_Main, ISLAND_FreqL2_Main, ISLAND_FreqL3_Main  FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_vitals3 ON powerwall BEGIN SELECT mean(ISLAND_VL1N_Load) AS ISLAND_VL1N_Load, mean(ISLAND_VL2N_Load) AS ISLAND_VL2N_Load, mean(ISLAND_VL3N_Load) AS ISLAND_VL3N_Load, mean(METER_X_VL1N) AS METER_X_VL1N, mean(METER_X_VL2N) AS METER_X_VL2N, mean(METER_X_VL3N) AS METER_X_VL3N INTO powerwall.vitals.:MEASUREMENT FROM (SELECT ISLAND_VL1N_Load, ISLAND_VL2N_Load, ISLAND_VL3N_Load, METER_X_VL1N, METER_X_VL2N, METER_X_VL3N  FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_vitals4 ON powerwall BEGIN SELECT mean(PW1_PINV_VSplit1) AS PW1_PINV_VSplit1, mean(PW2_PINV_VSplit1) AS PW2_PINV_VSplit1, mean(PW3_PINV_VSplit1) AS PW3_PINV_VSplit1, mean(PW4_PINV_VSplit1) AS PW4_PINV_VSplit1, mean(PW5_PINV_VSplit1) AS PW5_PINV_VSplit1, mean(PW6_PINV_VSplit1) AS PW6_PINV_VSplit1 INTO powerwall.vitals.:MEASUREMENT FROM (SELECT PW1_PINV_VSplit1, PW2_PINV_VSplit1, PW3_PINV_VSplit1, PW4_PINV_VSplit1, PW5_PINV_VSplit1, PW6_PINV_VSplit1  FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_vitals4b ON powerwall BEGIN SELECT mean(PW7_PINV_VSplit1) AS PW7_PINV_VSplit1, mean(PW8_PINV_VSplit1) AS PW8_PINV_VSplit1, mean(PW9_PINV_VSplit1) AS PW9_PINV_VSplit1, mean(PW10_PINV_VSplit1) AS PW10_PINV_VSplit1, mean(PW11_PINV_VSplit1) AS PW11_PINV_VSplit1, mean(PW12_PINV_VSplit1) AS PW12_PINV_VSplit1 INTO powerwall.vitals.:MEASUREMENT FROM (SELECT PW7_PINV_VSplit1, PW8_PINV_VSplit1, PW9_PINV_VSplit1, PW10_PINV_VSplit1, PW11_PINV_VSplit1, PW12_PINV_VSplit1  FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_vitals5 ON powerwall BEGIN SELECT mean(PW1_PINV_VSplit2) AS PW1_PINV_VSplit2, mean(PW2_PINV_VSplit2) AS PW2_PINV_VSplit2, mean(PW3_PINV_VSplit2) AS PW3_PINV_VSplit2, mean(PW4_PINV_VSplit2) AS PW4_PINV_VSplit2, mean(PW5_PINV_VSplit2) AS PW5_PINV_VSplit2, mean(PW6_PINV_VSplit2) AS PW6_PINV_VSplit2 INTO powerwall.vitals.:MEASUREMENT FROM (SELECT PW1_PINV_VSplit2, PW2_PINV_VSplit2, PW3_PINV_VSplit2, PW4_PINV_VSplit2, PW5_PINV_VSplit2, PW6_PINV_VSplit2  FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_vitals5b ON powerwall BEGIN SELECT mean(PW7_PINV_VSplit2) AS PW7_PINV_VSplit2, mean(PW8_PINV_VSplit2) AS PW8_PINV_VSplit2, mean(PW9_PINV_VSplit2) AS PW9_PINV_VSplit2, mean(PW10_PINV_VSplit2) AS PW10_PINV_VSplit2, mean(PW11_PINV_VSplit2) AS PW11_PINV_VSplit2, mean(PW12_PINV_VSplit2) AS PW12_PINV_VSplit2 INTO powerwall.vitals.:MEASUREMENT FROM (SELECT PW7_PINV_VSplit2, PW8_PINV_VSplit2, PW9_PINV_VSplit2, PW10_PINV_VSplit2, PW11_PINV_VSplit2, PW12_PINV_VSplit2  FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_vitals6 ON powerwall BEGIN SELECT mean(METER_Z_VL1G) AS METER_Z_VL1G, mean(METER_Z_VL2G) AS METER_Z_VL2G, mean(METER_Z_CTA_I) AS METER_Z_CTA_I, mean(METER_Z_CTB_I) AS METER_Z_CTB_I INTO powerwall.vitals.:MEASUREMENT FROM (SELECT METER_Z_VL1G, METER_Z_VL2G, METER_Z_CTA_I, METER_Z_CTB_I  FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_vitals7 ON powerwall BEGIN SELECT mean(ISLAND_VL1N_Main) AS ISLAND_VL1N_Main, mean(ISLAND_VL2N_Main) AS ISLAND_VL2N_Main, mean(ISLAND_VL3N_Main) AS ISLAND_VL3N_Main INTO powerwall.vitals.:MEASUREMENT FROM (SELECT ISLAND_VL1N_Main, ISLAND_VL2N_Main, ISLAND_VL3N_Main FROM raw.http) GROUP BY time(15s), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_vitals8 ON powerwall BEGIN SELECT mean(PW1_v_out) AS PW1_v_out, mean(PW2_v_out) AS PW2_v_out, mean(PW3_v_out) AS PW3_v_out, mean(PW4_v_out) AS PW4_v_out, mean(PW5_v_out) AS PW5_v_out, mean(PW6_v_out) AS PW6_v_out, mean(PW7_v_out) AS PW7_v_out, mean(PW8_v_out) AS PW8_v_out, mean(PW9_v_out) AS PW9_v_out, mean(PW10_v_out) AS PW10_v_out, mean(PW11_v_out) AS PW11_v_out, mean(PW12_v_out) AS PW12_v_out INTO powerwall.vitals.:MEASUREMENT FROM (SELECT PW1_v_out, PW2_v_out, PW3_v_out, PW4_v_out, PW5_v_out, PW6_v_out, PW7_v_out, PW8_v_out, PW9_v_out, PW10_v_out, PW11_v_out, PW12_v_out FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_vitals9 ON powerwall BEGIN SELECT mean(PW1_f_out) AS PW1_f_out, mean(PW2_f_out) AS PW2_f_out, mean(PW3_f_out) AS PW3_f_out, mean(PW4_f_out) AS PW4_f_out, mean(PW5_f_out) AS PW5_f_out, mean(PW6_f_out) AS PW6_f_out, mean(PW7_f_out) AS PW7_f_out, mean(PW8_f_out) AS PW8_f_out, mean(PW9_f_out) AS PW9_f_out, mean(PW10_f_out) AS PW10_f_out, mean(PW11_f_out) AS PW11_f_out, mean(PW12_f_out) AS PW12_f_out INTO powerwall.vitals.:MEASUREMENT FROM (SELECT PW1_f_out, PW2_f_out, PW3_f_out, PW4_f_out, PW5_f_out, PW6_f_out, PW7_f_out, PW8_f_out, PW9_f_out, PW10_f_out, PW11_f_out, PW12_f_out FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_vitals10 ON powerwall BEGIN SELECT mean(PW1_i_out) AS PW1_i_out, mean(PW2_i_out) AS PW2_i_out, mean(PW3_i_out) AS PW3_i_out, mean(PW4_i_out) AS PW4_i_out, mean(PW5_i_out) AS PW5_i_out, mean(PW6_i_out) AS PW6_i_out, mean(PW7_i_out) AS PW7_i_out, mean(PW8_i_out) AS PW8_i_out, mean(PW9_i_out) AS PW9_i_out, mean(PW10_i_out) AS PW10_i_out, mean(PW11_i_out) AS PW11_i_out, mean(PW12_i_out) AS PW12_i_out INTO powerwall.vitals.:MEASUREMENT FROM (SELECT PW1_i_out, PW2_i_out, PW3_i_out, PW4_i_out, PW5_i_out, PW6_i_out, PW7_i_out, PW8_i_out, PW9_i_out, PW10_i_out, PW11_i_out, PW12_i_out FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_vitals11 ON powerwall BEGIN SELECT mean(PW1_p_out) AS PW1_p_out, mean(PW2_p_out) AS PW2_p_out, mean(PW3_p_out) AS PW3_p_out, mean(PW4_p_out) AS PW4_p_out, mean(PW5_p_out) AS PW5_p_out, mean(PW6_p_out) AS PW6_p_out, mean(PW7_p_out) AS PW7_p_out, mean(PW8_p_out) AS PW8_p_out, mean(PW9_p_out) AS PW9_p_out, mean(PW10_p_out) AS PW10_p_out, mean(PW11_p_out) AS PW11_p_out, mean(PW12_p_out) AS PW12_p_out INTO powerwall.vitals.:MEASUREMENT FROM (SELECT PW1_p_out, PW2_p_out, PW3_p_out, PW4_p_out, PW5_p_out, PW6_p_out, PW7_p_out, PW8_p_out, PW9_p_out, PW10_p_out, PW11_p_out, PW12_p_out FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_vitals12 ON powerwall BEGIN SELECT mean(PW1_q_out) AS PW1_q_out, mean(PW2_q_out) AS PW2_q_out, mean(PW3_q_out) AS PW3_q_out, mean(PW4_q_out) AS PW4_q_out, mean(PW5_q_out) AS PW5_q_out, mean(PW6_q_out) AS PW6_q_out, mean(PW7_q_out) AS PW7_q_out, mean(PW8_q_out) AS PW8_q_out, mean(PW9_q_out) AS PW9_q_out, mean(PW10_q_out) AS PW10_q_out, mean(PW11_q_out) AS PW11_q_out, mean(PW12_q_out) AS PW12_q_out INTO powerwall.vitals.:MEASUREMENT FROM (SELECT PW1_q_out, PW2_q_out, PW3_q_out, PW4_q_out, PW5_q_out, PW6_q_out, PW7_q_out, PW8_q_out, PW9_q_out, PW10_q_out, PW11_q_out, PW12_q_out FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_grid ON powerwall BEGIN SELECT min(grid_status) AS grid_status INTO powerwall.grid.:MEASUREMENT FROM (SELECT grid_status FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_pod1 ON powerwall BEGIN SELECT mean(PW1_POD_nom_energy_remaining) AS PW1_POD_nom_energy_remaining, mean(PW2_POD_nom_energy_remaining) AS PW2_POD_nom_energy_remaining, mean(PW3_POD_nom_energy_remaining) AS PW3_POD_nom_energy_remaining, mean(PW4_POD_nom_energy_remaining) AS PW4_POD_nom_energy_remaining, mean(PW5_POD_nom_energy_remaining) AS PW5_POD_nom_energy_remaining, mean(PW6_POD_nom_energy_remaining) AS PW6_POD_nom_energy_remaining INTO powerwall.pod.:MEASUREMENT FROM (SELECT PW1_POD_nom_energy_remaining, PW2_POD_nom_energy_remaining, PW3_POD_nom_energy_remaining, PW4_POD_nom_energy_remaining, PW5_POD_nom_energy_remaining, PW6_POD_nom_energy_remaining FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_pod1b ON powerwall BEGIN SELECT mean(PW7_POD_nom_energy_remaining) AS PW7_POD_nom_energy_remaining, mean(PW8_POD_nom_energy_remaining) AS PW8_POD_nom_energy_remaining, mean(PW9_POD_nom_energy_remaining) AS PW9_POD_nom_energy_remaining, mean(PW10_POD_nom_energy_remaining) AS PW10_POD_nom_energy_remaining, mean(PW11_POD_nom_energy_remaining) AS PW11_POD_nom_energy_remaining, mean(PW12_POD_nom_energy_remaining) AS PW12_POD_nom_energy_remaining INTO powerwall.pod.:MEASUREMENT FROM (SELECT PW7_POD_nom_energy_remaining, PW8_POD_nom_energy_remaining, PW9_POD_nom_energy_remaining, PW10_POD_nom_energy_remaining, PW11_POD_nom_energy_remaining, PW12_POD_nom_energy_remaining FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_pod2 ON powerwall BEGIN SELECT mean(PW1_POD_nom_full_pack_energy) AS PW1_POD_nom_full_pack_energy, mean(PW2_POD_nom_full_pack_energy) AS PW2_POD_nom_full_pack_energy, mean(PW3_POD_nom_full_pack_energy) AS PW3_POD_nom_full_pack_energy, mean(PW4_POD_nom_full_pack_energy) AS PW4_POD_nom_full_pack_energy, mean(PW5_POD_nom_full_pack_energy) AS PW5_POD_nom_full_pack_energy, mean(PW6_POD_nom_full_pack_energy) AS PW6_POD_nom_full_pack_energy INTO powerwall.pod.:MEASUREMENT FROM (SELECT PW1_POD_nom_full_pack_energy, PW2_POD_nom_full_pack_energy, PW3_POD_nom_full_pack_energy, PW4_POD_nom_full_pack_energy, PW5_POD_nom_full_pack_energy, PW6_POD_nom_full_pack_energy FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_pod2b ON powerwall BEGIN SELECT mean(PW7_POD_nom_full_pack_energy) AS PW7_POD_nom_full_pack_energy, mean(PW8_POD_nom_full_pack_energy) AS PW8_POD_nom_full_pack_energy, mean(PW9_POD_nom_full_pack_energy) AS PW9_POD_nom_full_pack_energy, mean(PW10_POD_nom_full_pack_energy) AS PW10_POD_nom_full_pack_energy, mean(PW11_POD_nom_full_pack_energy) AS PW11_POD_nom_full_pack_energy, mean(PW12_POD_nom_full_pack_energy) AS PW12_POD_nom_full_pack_energy INTO powerwall.pod.:MEASUREMENT FROM (SELECT PW7_POD_nom_full_pack_energy, PW8_POD_nom_full_pack_energy, PW9_POD_nom_full_pack_energy, PW10_POD_nom_full_pack_energy, PW11_POD_nom_full_pack_energy, PW12_POD_nom_full_pack_energy FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_pod3 ON powerwall BEGIN SELECT mean(backup_reserve_percent) AS backup_reserve_percent INTO powerwall.pod.:MEASUREMENT FROM (SELECT backup_reserve_percent FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_pod4 ON powerwall BEGIN SELECT mean(nominal_full_pack_energy) AS nominal_full_pack_energy, mean(nominal_energy_remaining) AS nominal_energy_remaining INTO powerwall.pod.:MEASUREMENT FROM (SELECT nominal_full_pack_energy, nominal_energy_remaining FROM raw.http) GROUP BY time(1m), month, year fill(linear) END
CREATE CONTINUOUS QUERY cq_alerts ON powerwall RESAMPLE FOR 2m BEGIN SELECT max(*) INTO powerwall.alerts.:MEASUREMENT FROM (SELECT * FROM raw.alerts) GROUP BY time(1m), month, year END
