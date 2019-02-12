create table DO_CORR (lakeID text, location text, depth_m real, dateTime text, dayfrac real, changesCodeTemp text, changesCodeDO text, cleanedTemp_C real, cleanedDO_mg_L real);
create table DO_RAW (lakeID text, location text, depth_m real, dateTime text, dayfrac real, temp_C real, DO_mg_L real);
create table HOBO_METSTATION_CORR (lakeID text, location text, dateTime text, dayfrac real, changesCodePress text, changesCodePAR text, changesCodeWindSpeed text, changesCodeWindGust text, changesCodeWindDir text, changesCodeTemp text, changesCodeRH text, changesCodeDewPoint text, cleanedAtmPressure_kPa real, cleanedPAR_uE_m2_s real, cleanedWindSpeed_m_s real, cleanedWindGust_m_s real, cleanedWindDir_deg real, cleanedTemp_C real, cleanedRH_pct real, cleanedDewPoint_C real);
create table HOBO_METSTATION_RAW (lakeID text, location text, dateTime text, dayfrac real, atmPressure_kPa real, PAR_uE_m2_s real, windSpeed_m_s real, windGust_m_s real, windDir_deg real, temp_C real, RH_pct real, dewPoint_C real);
create table HOBO_PRESS_CORR (lakeID text, location text, dateTime text, dayfrac real, changesCodeTemp text, changesCodePress text, cleanedTemp_C real, cleanedPress_kPa real);
create table HOBO_PRESS_RAW (lakeID text, location text, dateTime text, dayfrac real, temp_C real, press_kPa real);
create table HOBO_TCHAIN_CORR (lakeID text, location text, depth_m real, dateTime text, dayfrac real, changesCodeTemp text, changesCodeLight text, cleanedTemp_C real, cleanedLight_lux real);
create table HOBO_TCHAIN_RAW (lakeID text, location text, depth_m real, dateTime text, dayfrac real, temp_C real, light_lux real);
create table YSI_CORR (lakeID text, location text, depth_m real, dateTime text, dayfrac real, changesCodeTemp text, changesCodeDO text, cleanedTemp_C real, cleanedDO_mg_L real, spcond_uS_cm real, pH real, pH_mV real, DO_pctSat real, batt_V real);
create table YSI_RAW (lakeID text, location text, depth_m real, dateTime text, dayfrac real, temp_C real, DO_mg_L real, spcond_uS_cm real, pH real, pH_mV real, DO_pctSat real, batt_V real);
create table PRECIP_CORR (lakeID text, location text, dateTime text, dayfrac real, changesCodePrecip text, cleanedPrecip_mm real);
create table PRECIP_RAW (lakeID text, location text, dateTime text, dayfrac real, precip_mm real);

.separator "|"

.import DO_CORR.txt DO_CORR
.import DO_RAW.txt DO_RAW
.import HOBO_METSTATION_CORR.txt HOBO_METSTATION_CORR
.import HOBO_METSTATION_RAW.txt HOBO_METSTATION_RAW
.import HOBO_PRESS_CORR.txt HOBO_PRESS_CORR
.import HOBO_PRESS_RAW.txt HOBO_PRESS_RAW
.import HOBO_TCHAIN_CORR.txt HOBO_TCHAIN_CORR
.import HOBO_TCHAIN_RAW.txt HOBO_TCHAIN_RAW
.import YSI_CORR.txt YSI_CORR
.import YSI_RAW.txt YSI_RAW
.import PRECIP_CORR.txt PRECIP_CORR
.import PRECIP_RAW.txt PRECIP_RAW