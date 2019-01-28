//
//  TAS5558.h
//  
//
//  Created by Artem Khlyupin on 04/07/2018.
//

#ifndef TAS5558_h
#define TAS5558_h


#define I2C_ADDR 				0x34
#define TAS5558_FS  			96000

//Regiser Map
#define CLOCK_CONTROL_REG					0x00
#define GENERAL_STATUS_REG                  0x01
#define ERROR_STATUS_REG                    0x02
#define SYSTEM_CONTROL1_REG                 0x03
#define SYSTEM_CONTROL2_REG                 0x04

#define CH1_CONFIG_CONTROL_REG              0x05
#define CH2_CONFIG_CONTROL_REG              0x06
#define CH3_CONFIG_CONTROL_REG              0x07
#define CH4_CONFIG_CONTROL_REG              0x08
#define CH5_CONFIG_CONTROL_REG              0x09
#define CH6_CONFIG_CONTROL_REG              0x0A
#define CH7_CONFIG_CONTROL_REG              0x0B
#define CH8_CONFIG_CONTROL_REG              0x0C

#define HEADPHONE_CONFIG_CONTROL_REG        0x0D
#define SERIAL_DATA_INTERFACE_CONTROL_REG   0x0E
#define SOFT_MUTE_REG                       0x0F
#define ENERGY_MANAGERS_REG                 0x10
#define RESERVED0                           0x11
#define OSCILLATOR_TRIM                     0x12
#define RESERVED                            0x13
#define AUTOMUTE_CONTROL1_REG               0x14
#define AUTOMUTE_CONTROL2_REG               0x15

#define MODULATION12_LIMIT_REG              0x16
#define MODULATION34_LIMIT_REG              0x17
#define MODULATION56_LIMIT_REG              0x18
#define MODULATION78_LIMIT_REG              0x19
#define RESERVED1                           0x1A

#define DELAY_CH1_REG                       0x1B
#define DELAY_CH2_REG                       0x1C
#define DELAY_CH3_REG                       0x1D
#define DELAY_CH4_REG                       0x1E
#define DELAY_CH5_REG                       0x1F
#define DELAY_CH6_REG                       0x20
#define DELAY_CH7_REG                       0x21
#define DELAY_CH8_REG                       0x22

#define OFFSET_DELAY_REG                    0x23
#define PWM_SEQUENCE_TIMING_REG             0x24
#define PWM_ENERGY_MANAGER_REG              0x25
#define RESERVED2                           0x26
#define INDIVIDUAL_CH_SHUTDOWN_REG          0x27
#define RESERVED3                           0x28//0x28-0x2F

#define INPUT_MUX_CH12_REG                  0x30
#define INPUT_MUX_CH34_REG                  0x31
#define INPUT_MUX_CH56_REG                  0x32
#define INPUT_MUX_CH78_REG                  0x33

#define PWM_MUX_CH12_REG                    0x34
#define PWM_MUX_CH34_REG                    0x35
#define PWM_MUX_CH56_REG                    0x36
#define PWM_MUX_CH78_REG                    0x37

#define DELAY_CH1_BD_MODE_REG               0x38
#define DELAY_CH2_BD_MODE_REG               0x39
#define DELAY_CH3_BD_MODE_REG               0x3A
#define DELAY_CH4_BD_MODE_REG               0x3B
#define DELAY_CH5_BD_MODE_REG               0x3C
#define DELAY_CH6_BD_MODE_REG               0x3D
#define DELAY_CH7_BD_MODE_REG               0x3E
#define DELAY_CH8_BD_MODE_REG               0x3F

#define BANK_SWITCHING_CMD_REG              0x40
#define INPUT_MIXER_REG                     0x41//0x41-0x48

#define BASS_MIXER                          0x49//0x49-0x50
#define BIQUAD_FILTER_REG                   0x51//0x51-0x88, 7biquads * 8channels
#define BASS_TREBLE_REG                     0x89//0x89-0x90

#define LOUDNESS_LOG2_GAIN_REG              0x91
#define LOUDNESS_LOG2_OFFSET_REG            0x92
#define LOUDNESS_GAIN_REG                   0x93
#define LOUDNESS_OFFSET_REG                 0x94
#define LOUDNESS_BIQUAD_REG                 0x95

#define DRC1_CONTROL_REG                    0x96
#define DRC2_CONTROL_REG                    0x97

#define DRC1_ENERGY_REG                     0x98
#define DRC1_THRESHOLD_REG                  0x99
#define DRC1_SLOPE_REG                      0x9A
#define DRC1_OFFSET_REG                     0x9B
#define DRC1_ATTACK_DECAY_REG               0x9C

#define DRC2_ENERGY_REG                     0x9D
#define DRC2_THRESHOLD_REG                  0x9E
#define DRC2_SLOPE_REG                      0x9F
#define DRC2_OFFSET_REG                     0xA0
#define DRC2_ATTACK_DECAY_REG               0xA1

#define DRC_BYPASS1_REG                     0xA2
#define DRC_BYPASS2_REG                     0xA3
#define DRC_BYPASS3_REG                     0xA4
#define DRC_BYPASS4_REG                     0xA5
#define DRC_BYPASS5_REG                     0xA6
#define DRC_BYPASS6_REG                     0xA7
#define DRC_BYPASS7_REG                     0xA8
#define DRC_BYPASS8_REG                     0xA9

#define OUTPUT_TO_PWM1_REG                  0xAA
#define OUTPUT_TO_PWM2_REG                  0xAB
#define OUTPUT_TO_PWM3_REG                  0xAC
#define OUTPUT_TO_PWM4_REG                  0xAD
#define OUTPUT_TO_PWM5_REG                  0xAE
#define OUTPUT_TO_PWM6_REG                  0xAF
#define OUTPUT_TO_PWM7_REG                  0xB0
#define OUTPUT_TO_PWM8_REG                  0xB1

#define ENERGY_MANAGER_AVERAGING_REG        0xB2
#define ENERGY_MANAGER_WEIGHTING_CH1_REG    0xB3
#define ENERGY_MANAGER_WEIGHTING_CH2_REG    0xB4
#define ENERGY_MANAGER_WEIGHTING_CH3_REG    0xB5
#define ENERGY_MANAGER_WEIGHTING_CH4_REG    0xB6
#define ENERGY_MANAGER_WEIGHTING_CH5_REG    0xB7
#define ENERGY_MANAGER_WEIGHTING_CH6_REG    0xB8
#define ENERGY_MANAGER_WEIGHTING_CH7_REG    0xB9
#define ENERGY_MANAGER_WEIGHTING_CH8_REG    0xBA

#define ENERGY_MANAGER_HIGH_THRESHOLD_SATELLITE_REG 0xBB
#define ENERGY_MANAGER_LOW_THRESHOLD_SATELLITE_REG  0xBC
#define ENERGY_MANAGER_HIGH_THRESHOLD_SUBWOOFER_REG 0xBD
#define ENERGY_MANAGER_LOW_THRESHOLD_SUBWOOFER_REG  0xBE
#define RESERVED4                                   0xBF//0xBF–0xC2 

#define ASRC_STATUS_REG                             0xC3
#define ASRC_CONTROL_REG                            0xC4
#define ASRC_MODE_CONTROL_REG                       0xC5
#define RESERVED5                                   0xC6// 0xC6-0xCB

#define AUTO_MUTE_BEHAVIOUR                         0xCC
#define RESERVED6                                   0xCD
#define PSVC_VOLUME_BIQUAD                          0xCF
#define VOLUME_TREBLE_BASS_SLEW_RATES_REG           0xD0

#define CH1_VOLUME_REG                              0xD1
#define CH2_VOLUME_REG                              0xD2
#define CH3_VOLUME_REG                              0xD3
#define CH4_VOLUME_REG                              0xD4
#define CH5_VOLUME_REG                              0xD5
#define CH6_VOLUME_REG                              0xD6
#define CH7_VOLUME_REG                              0xD7
#define CH8_VOLUME_REG                              0xD8
#define MASTER_VOLUME_REG                           0xD9

#define BASS_FILTER_SET_REG                         0xDA
#define BASS_FILTER_INDEX_REG                       0xDB
#define TREBLE_FILTER_SET_REG                       0xDC
#define TREBLE_FILTER_INDEX_REG                     0xDD
#define AM_MODE_REG                                 0xDE
#define PSVC_RANGE_REG                              0xDF
#define GENERAL_CONTROL_REG                         0xE0
#define RESERVED7                                   0xE1//0xE1-0xE2

#define R_DOLBY_COEFLR_REG                          0xE3
#define R_DOLBY_COEFC_REG                           0xE4
#define R_DOLBY_COEFLSP_REG                         0xE5
#define R_DOLBY_COEFRSP_REG                         0xE6
#define R_DOLBY_COEFLSM_REG                         0xE7
#define R_DOLBY_COEFRSM_REG                         0xE8

#define THD_MANAGER_PRE_REG                         0xE9
#define THD_MANAGER_POST_REG                        0xEA
#define RESERVED8                                   0xEB

#define SDIN5_INPUT1_MIX_REG                        0xEC
#define SDIN5_INPUT2_MIX_REG                        0xED
#define SDIN5_INPUT3_MIX_REG                        0xEE
#define SDIN5_INPUT4_MIX_REG                        0xEF
#define SDIN5_INPUT5_MIX_REG                        0xF0
#define SDIN5_INPUT6_MIX_REG                        0xF1
#define SDIN5_INPUT7_MIX_REG                        0xF2
#define SDIN5_INPUT8_MIX_REG                        0xF3

#define KHZ192_PROCESS_FLOW_OUTPUT_MIX1_REG         0xF4
#define KHZ192_PROCESS_FLOW_OUTPUT_MIX2_REG         0xF5
#define KHZ192_PROCESS_FLOW_OUTPUT_MIX3_REG         0xF6
#define KHZ192_PROCESS_FLOW_OUTPUT_MIX4_REG         0xF7
#define RESERVED9                                   0xF8//0xF8-0xF9

#define KHZ192_IMAGE_SELECT_REG                     0xFA
#define KHZ192_DOLBY_DOWNMIX_COEF_REG               0xFB
#define RESERVED10                                  0xFD

#define SPECIAL_REG                                 0xFE
#define RESERVED11                                  0xFF

//Clock Control Register Masks
#define DATA_RATE_MASK								0xE0
#define DATA_RATE_32KHZ								0x00
#define DATA_RATE_44_1KHZ							0x40
#define DATA_RATE_48KHZ								0x60
#define DATA_RATE_88_2KHZ							0x80
#define DATA_RATE_96KHZ								0xA0
#define DATA_RATE_176_4KHZ							0xC0
#define DATA_RATE_192KHZ							0xE0

#define MCLK_FREQ_MASK								0x1C
#define MCLK_FREQ_64								0x00
#define MCLK_FREQ_128								0x04
#define MCLK_FREQ_192								0x08
#define MCLK_FREQ_256								0x0C
#define MCLK_FREQ_384								0x10
#define MCLK_FREQ_512								0x14
#define MCLK_FREQ_768								0x18

#define CLK_REG_VALID_MASK							0x03
#define CLK_REG_VALID								0x01
#define CLK_REG_NOT_VALID							0x00

//Error Status Register Masks
#define FRAME_SLIP_MASK								0x08
#define CLIP_INDICATOR_MASK							0x04
#define FAULTZ_MASK									0x02




#endif /* TAS5558_h */
