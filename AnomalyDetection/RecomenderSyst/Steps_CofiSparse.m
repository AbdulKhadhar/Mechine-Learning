tol = 0.2; % Target mean absolute prediction error on existing ratings
lambda = 0.5; % Regularization strength
nf = 100; % Number of latent features
[X,Theta,movieBias,userBias] = cofiGrad(R,nf,tol,lambda);

myCofiRating = (X(end,:)*Theta+movieBias+userBias(end)+globalMean)';
myCofiRating(tbl.numRatings < 10) = globalMean;
tbl = addvars(tbl,myCofiRating,'After','myNNrating')

% Add sorting and filtering commands for your
% table here:


writetable(tbl,'MovieRecommendations.csv')
