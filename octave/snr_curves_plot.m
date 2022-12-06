% snr_curves_plot.m
%
% Companion script for unittest/raw_data_curves

1;

function state_vec = set_graphics_state_print()
  textfontsize = get(0,"defaulttextfontsize");
  linewidth = get(0,"defaultlinelinewidth");
  markersize = get(0, "defaultlinemarkersize");
  set(0, "defaulttextfontsize", 16);
  set(0, "defaultaxesfontsize", 16);
  set(0, "defaultlinelinewidth", 1);
  state_vec = [textfontsize linewidth markersize];
endfunction

function set_graphics_state_screen(state_vec) 
  textfontsize = state_vec(1);
  linewidth = state_vec(2);
  markersize = state_vec(3);
  set(0, "defaulttextfontsize", textfontsize);
  set(0, "defaultaxesfontsize", textfontsize);
  set(0, "defaultlinelinewidth", linewidth);  
  set(0, "defaultlinemarkersize", markersize);
endfunction

function [snr_ch per] = snr_scatter(source, mode, channel, colour)
  suffix = sprintf("_%s_%s_%s",source, mode, channel)
  snr = load(sprintf("snr%s.txt",suffix));
  offset = load(sprintf("offset%s.txt",suffix));
  snr -= offset;
  snr_x = []; snrest_y = [];
  for i=1:length(snr)
    fn = sprintf('snrest%s_%d.txt',suffix,i);
    if exist(fn,'file') == 2
      snrest=load(fn);
      if i == length(snr)
        plot(snr(i)*ones(1,length(snrest)), snrest, sprintf('%s;%s %s;',colour,source,mode));
      else
        plot(snr(i)*ones(1,length(snrest)), snrest, sprintf('%s',colour));
      end
      snr_x = [snr_x snr(i)]; snrest_y = [snrest_y mean(snrest)];
    end
  end
  plot(snr_x, snrest_y, sprintf('%s', colour));
endfunction

function [snr_ch per] = per_snr(mode, colour)
  snrch = load(sprintf("snrch_%s.txt",mode));
  snroffset = load(sprintf("snroffset_%s.txt",mode));
  snrch -= snroffset; 
  per = load(sprintf("per_%s.txt",mode));
  plot(snrch, per, sprintf('%so-;%s;', colour, mode));
endfunction

function snrest_snr_screen(channel)
  clf; hold on;
  snr_scatter('ctx', 'datac0', channel,'b+-')
  snr_scatter('ctx', 'datac1', channel,'g+-')
  snr_scatter('ctx', 'datac3', channel,'r+-')
  xlabel('SNR (dB)'); ylabel('SNRest (dB)'); grid('minor');
  a = axis;
  plot([a(1) a(2)],[a(1) a(2)],'bk-');
  hold off; grid;
  title(sprintf('SNR estimate versus SNR (%s)', channel));
  legend('location','northwest');
endfunction

function snrest_snr_print(channel)
  state_vec = set_graphics_state_print();
  snrest_snr_screen(channel);
  print("snrest_snr.png", "-dpng", "-S800,600");
  set_graphics_state_screen(state_vec);
endfunction

% we need different font sizes for printing
function per_snr_screen(channel)
  clf; hold on;
  per_snr('datac0',channel,'b')
  per_snr('datac1',channel,'g')
  per_snr('datac3',channel,'r')
  xlabel('SNR (dB)'); ylabel('PER'); grid;
  hold off;
endfunction

% we need different font sizes for printing
function per_snr_print
  textfontsize = get(0,"defaulttextfontsize");
  linewidth = get(0,"defaultlinelinewidth");
  markersize = get(0, "defaultlinemarkersize");
  set(0, "defaulttextfontsize", 10);
  set(0, "defaultaxesfontsize", 10);
  set(0, "defaultlinelinewidth", 0.5);
  
  per_snr_screen;
  print("per_snr.png", "-dpng", "-S500,500");

  % restore plot defaults
  set(0, "defaulttextfontsize", textfontsize);
  set(0, "defaultaxesfontsize", textfontsize);
  set(0, "defaultlinelinewidth", linewidth);  
  set(0, "defaultlinemarkersize", markersize);
endfunction

function ber_per_v_snr(source, mode, channel, colour)
  suffix = sprintf("_%s_%s_%s.txt",source, mode, channel);
  snr = load(sprintf("snr%s",suffix));
  offset = load(sprintf("offset%s",suffix));
  snr -= offset;
  ber = load(sprintf("ber%s",suffix)) + 1E-6;
  per = load(sprintf("per%s",suffix)) + 1E-6;
  semilogy(snr, ber, sprintf('%s;%s %s ber;', colour, source, mode));
  semilogy(snr, per, sprintf('%s;%s %s per;', colour, source, mode));
 endfunction

function octave_ch_noise_screen(channel)
  clf; hold on;
  ber_per_v_snr('oct','datac0',channel,'bo-')
  ber_per_v_snr('ch' ,'datac0',channel,'bx-')
  ber_per_v_snr('oct','datac1',channel,'go-')
  ber_per_v_snr('ch' ,'datac1',channel,'gx-')
  ber_per_v_snr('oct','datac3',channel,'ro-')
  ber_per_v_snr('ch' ,'datac3',channel,'rx-')
  xlabel('SNR (dB)'); grid;
  hold off; axis([-6 8 1E-3 1]);
  title(sprintf('Comparsion of Measuring SNR from Octave and ch tool (%s)', channel));
endfunction

function octave_ch_noise_print(channel)
  state_vec = set_graphics_state_print();
  octave_ch_noise_screen(channel);
  print(sprintf("octave_ch_noise_%s.png", channel), "-dpng","-S800,600");
  set_graphics_state_screen(state_vec);
endfunction

function octave_c_tx_screen(channel)
  clf; hold on;
  ber_per_v_snr('oct','datac0',channel,'bo-')
  ber_per_v_snr('ctx','datac0',channel,'bx-')
  ber_per_v_snr('oct','datac1',channel,'go-')
  ber_per_v_snr('ctx','datac1',channel,'gx-')
  ber_per_v_snr('oct','datac3',channel,'ro-')
  ber_per_v_snr('ctx','datac3',channel,'rx-')
  xlabel('SNR (dB)'); grid;
  hold off; axis([-6 8 1E-3 1]);
  title(sprintf('Comparsion of Octave Tx and C Tx (no compression) (%s)', channel));
endfunction

function octave_c_tx_print(channel)
  state_vec = set_graphics_state_print();
  octave_c_tx_screen(channel);
  print(sprintf("octave_c_tx_%s.png", channel), "-dpng","-S800,600");
  set_graphics_state_screen(state_vec);
endfunction

function octave_c_tx_comp_screen(channel)
  clf; hold on;
  ber_per_v_snr('oct','datac0',channel,'bo-')
  ber_per_v_snr('ctxc','datac0',channel,'bx-')
  ber_per_v_snr('oct','datac3',channel,'ro-')
  ber_per_v_snr('ctxc','datac3',channel,'rx-')
  xlabel('SNR (dB)'); grid;
  hold off; axis([-6 8 1E-3 1]);
  title(sprintf('Comparsion of Octave Tx and C Tx (with compression) (%s)', channel));
endfunction

function octave_c_tx_comp_print(channel)
  state_vec = set_graphics_state_print();
  octave_c_tx_comp_screen(channel);
  print(sprintf("octave_c_tx_comp_%s.png", channel), "-dpng","-S800,600");
  set_graphics_state_screen(state_vec);
endfunction

#{
figure(1); octave_ch_noise_screen;
figure(2); octave_c_tx_screen;
figure(3); octave_c_tx_comp_screen
figure(4); snrest_snr_screen;

figure(5); octave_ch_noise_print;
figure(6); octave_c_tx_print;
figure(7); octave_c_tx_comp_print;
figure(8); snrest_snr_print;
#}
