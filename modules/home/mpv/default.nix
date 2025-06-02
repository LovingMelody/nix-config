{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.TM.programs.mpv;
  inherit (lib) mkEnableOption mkForce mkIf;
in {
  options.TM.programs.mpv.enable =
    mkEnableOption "General-purpose media player, fork of MPlayer and mplayer2";
  config = mkIf cfg.enable {
    programs.mpv = {
      enable = true;
      # package = pkgs.mpv-unwrapped;
      bindings = with pkgs; {
        "CTRL+1" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A (HQ)"'';
        "CTRL+2" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B (HQ)"'';
        "CTRL+3" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C (HQ)"'';
        "CTRL+4" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A+A (HQ)"'';
        "CTRL+5" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B+B (HQ)"'';
        "CTRL+6" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C+A (HQ)"'';

        "CTRL+0" = ''no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"'';
        "SPACE" = "cycle pause";
        "CTRL+Q" = "quit";
      };
      scripts = with pkgs.mpvScripts; [
        dynamic-crop
        mpris
        mpv-cheatsheet
        sponsorblock
        uosc
        videoclip
        vr-reversal
        youtube-upnext
      ];
      config = {
        profile = "gpu-hq";
        gpu-api = "opengl";

        ytdl-format = "bestvideo+bestaudio";
        include = mkForce [
          (config.catppuccin.sources.mpv + "/${config.catppuccin.flavor}/${config.catppuccin.accent}.conf")
        ];
        # vo = "kitty";
        #scale="ewa_lanczossharp";
        #cscale="ewa_lanczossharp";
        #video-sync="display-resample";
        #tscale="oversample";
        #hls-bitrate="max"; # use max quality for HLS streams
        #audio-pitch-correction="yes";
        #hwdec-codecs="all"; # Vapoursynth
        # Vulkan settings
        #gpu-api="vulkan";
        #vulkan-async-compute="yes";
        #vulkan-async-transfer="yes";
        #vulkan-queue-count=1;
        #vd-lavc-dr="yes";
        #hwdec="auto"; # enable best HW decoder; turn off for software decoding

        # see https://github.com/mpv-player/mpv/wiki/Video-output---shader-stage-diagram
        #target-prim="auto";
        #target-trc="auto";
        #vf="format=colorlevels=full:colormatrix=auto";
        #video-output-levels="full";
        #interpolation="yes";
      };
    };
  };
}
