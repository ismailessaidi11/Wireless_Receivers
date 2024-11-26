clc,clear

% load the received samples
load diversity_task

% Constellation and pilot symbol

pilot_symb = (1+1j)/sqrt(2);

% ToDo 1.1:
constellation = (1/sqrt(2))* [(-1-1j) (-1+1j) ( 1-1j) ( 1+1j)];
h1_est = signal(1)/pilot_symb;

% ToDo 1.2:
signal_1 = signal(2:113)/h1_est;
msg1 = decode_msg(signal_1,constellation);

% ToDo 1.3:

h2_est = signal(1001)/pilot_symb;
signal_2 = signal(1002:1113)/h2_est;
msg2 = decode_msg(signal_2,constellation);

% ToDo 1.4
h_comb = [h1_est ;h2_est];
h_comb_conj = conj(h_comb);
h_mf = h_comb_conj/norm(h_comb_conj)^2;
signal_comb_chan = [signal_1  signal_2];
signal_comb = h_mf *signal_comb_chan;

msg_comb = decode_msg(signal_comb,constellation);
    
% Plot and save the constellation
% ToDo 1.5
% subplot containing the received symbols
subplot(1,2,1)
plot(signal_comb, '.','Markersize',12),hold on
    
grid on,hold on,axis square
    
plot(constellation,'x','Markersize',12)
xlabel("Real")
ylabel("Imag")

title({strcat("Message frame 1: ",msg1);
       strcat("Message frame 2: ",msg2);
       strcat("Message combined: ",msg_comb)})

% subplot printing the decoded message strings
subplot(1,2,2)
axis off
text(0.2, 0.5,{strcat("Message frame 1: "+newline,msg1);newline; ...
            strcat("Message frame 2: "+newline,msg2);newline; ...
            strcat("Message combined: "+newline,msg_comb)}, 'Units', 'normalized','Fontname','Monospaced', 'Interpreter', 'none');
set(gcf, 'Position', [100, 100, 1000, 500]);

saveas(gcf,'P2T1_const.png')



