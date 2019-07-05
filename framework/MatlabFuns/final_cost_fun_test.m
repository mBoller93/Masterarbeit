function [V_F] = final_cost_fun_test(x_pred_N, finalConstraints, N_pred, k, common, instance, ~)
%FINAL_COST_FUN_TEST Summary of this function goes here

V_F = ( x_pred_N(2) - 22 ).' * 1000 * (x_pred_N(2) - 22);

end

